from sqlalchemy import create_engine, text
import psycopg

from datetime import datetime, timedelta, date
import calendar
import subprocess
import os
import sys

sys.stdout.reconfigure(line_buffering=True)

import builtins
from datetime import datetime

# Override print globally
def print(*args, **kwargs):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    builtins.print(f"{timestamp} -", *args, **kwargs)


def generate_5_day_intervals(start_date_str, end_date_str):
  # Parse input dates
  start_date = datetime.strptime(start_date_str, "%Y-%m-%d")
  end_date = datetime.strptime(end_date_str, "%Y-%m-%d")

  intervals = []
  current_start = start_date

  while current_start <= end_date:
      current_end = min(current_start + timedelta(days=4), end_date)
      intervals.append((
          current_start.strftime("%Y-%m-%d 00:00:00"),
          current_end.strftime("%Y-%m-%d 23:59:59")
      ))
      current_start = current_end + timedelta(days=1)

  return intervals

# Get the current folder
script_dir = os.path.dirname(os.path.abspath(__file__))

# Target script path (in same folder)
target_script = os.path.join(script_dir, "Staging_SqlScript.py")

StartDate = sys.argv[1]
EndDate = sys.argv[2]
#TableName = sys.argv[3]

start_date = datetime.strptime(StartDate, '%Y-%m-%d')
end_date = datetime.strptime(EndDate, '%Y-%m-%d')

# Loop through months
current = start_date
try:
  while current <= end_date:
    year = current.year
    month = current.month

    # First and last day of the current month
    start_of_month = datetime(year, month, 1)
    last_day = calendar.monthrange(year, month)[1]
    #end_of_month = datetime(year, month, last_day)
    end_of_month = datetime(year, month, last_day, 23, 59, 59)

    # Format Month without dash
    month_str = f"{year}{month:02}"  # e.g., "202001"
          
    # Print result
    print(f"Month: {month_str}")

    # Move to next month
    if month == 12:
      current = datetime(year + 1, 1, 1)
    else:
      current = datetime(year, month + 1, 1)
      
    table_scripts = [
        ("ACC_Account.sql" , "ACC_Account", ['AccountId']) , 
        ("ACC_DebitOrder.sql" , "ACC_DebitOrder", ['DebitOrderId']),
        ("ACC_Schedules.sql" , "ACC_Schedules", ['AccountId','Installment_SrNo']),
        ("Address.sql" , "Address", ['AddressId']),
        ("Affordability.sql" , "Affordability", ['AffordabilityId']),
        ("Application.sql" , "Application", ['ApplicationId']),
        ("Application_AccountMapping.sql" , "Application_AccountMapping", ['ApplicationAccountMappingId']),
        ("Application_Client.sql" , "Application_Client", ['ApplicationClientId']),
        ("BankDetail.sql" , "BankDetail", ['BankDetailId']),
        ("Client.sql" , "Client", ['ClientId']),
        ("CreditScore.sql" , "CreditScore", ['CreditScoreId']),
        ("Disbursement.sql" , "Disbursement", ['DisbursementId']),
        ("Employer.sql" , "Employer", ['EmployerId']),
        ("PER_Person.sql" , "PER_Person", ['PersonId']),
        ("Quotation.sql" , "Quotation", ['QuotationId']),
        ("ACC_PaymentStatusHistory.sql" , "ACC_PaymentStatusHistory", ['PaymentStatusHistoryId'])
      ]
    table_scripts = [
      ("ACC_Account.sql" , "ACC_Account_202506_202508", ['AccountId']),
      ("ACC_Schedules.sql" , "ACC_Schedules_202506_202508", ['AccountId','Installment_SrNo'])
    ]   


    # Collect all the related tables
    for script_file, table_name, key_columns in table_scripts:
      print(f"Processing {table_name} for {month_str}...{str(start_of_month)}..{str(end_of_month)}")
      subprocess.run(
          ["python", target_script, "history", str(start_of_month), str(end_of_month),
          script_file, table_name] + key_columns,
          check=True
      )

    # Collect the bureau data for the month in question in week intervals due to the db not able to handle more than 7 days worth of data.
    #intervals = generate_5_day_intervals(str(start_of_month.date()), str(end_of_month.date()))
    #for start, end in intervals:
    #  print(f"Processing XDSCustomerDetailsLog... {start} to {end}")
    #  subprocess.run(
    #        ["python", target_script , "history", start, end, "XDSCustomerDetailsLog.sql", "XDSCustomerDetailsLog"] + ['ApplicationId','Type'],
    #        check=True  # Raises CalledProcessError on failure
    #    )
    #  print(f"{start} to {end}")

except subprocess.CalledProcessError as e:
    print(f"Error: Subprocess failed with exit code {e.returncode}. Command: {' '.join(e.cmd)}")
    exit(1)
except Exception as e:
    print(f"Unexpected error: {e}")
    exit(1)

exit()
# Create connection string
MatogenDB = "postgresql+psycopg://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"
targetDB = create_engine(MatogenDB)

#Merge the data into the results table Loan
def handle_notice(notice):
  print("NOTICE:", notice.message.strip())

with targetDB.connect().execution_options(isolation_level="AUTOCOMMIT") as conn:
  raw_conn = conn.connection.driver_connection
  raw_conn.add_notice_handler(handle_notice)

  conn.execute(text("SET client_min_messages TO NOTICE"))
  conn.execute(text("CALL prod.\"Loan_Detail_From_Staging\"()"))

