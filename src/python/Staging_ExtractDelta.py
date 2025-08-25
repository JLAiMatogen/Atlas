from sqlalchemy import create_engine, text
from datetime import datetime
import calendar
import subprocess
import os
import sys

import os
import sys

import builtins
from datetime import datetime
# Override print globally
def print(*args, **kwargs):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    builtins.print(f"{timestamp} -", *args, **kwargs)

# Get the current folder
script_dir = os.path.dirname(os.path.abspath(__file__))

# Target script path (in same folder)
target_script = os.path.join(script_dir, "Staging_SqlScript.py")

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
    ("ACC_PaymentStatusHistory.sql" , "ACC_PaymentStatusHistory", ['PaymentStatusHistoryId']),
    ("XDSCustomerDetailsLog.sql", "XDSCustomerDetailsLog", ['ApplicationId','Type'])
  ]

table_scripts = [
    ("ACC_Account.sql" , "ACC_Account", ['AccountId']) , 
    ("ACC_Schedules.sql" , "ACC_Schedules", ['AccountId','Installment_SrNo'])
]

print(f"Processing Deltas ...")
# Collect all the related tables
try:
  for script_file, table_name, key_columns in table_scripts:
          print(f"Start {table_name}")
          subprocess.run(
              ["python", target_script, "delta", "", "", script_file, table_name] + key_columns,
              check=True  # Raises CalledProcessError on failure
          )

except subprocess.CalledProcessError as e:
    print(f"Error: Subprocess failed with exit code {e.returncode}. Command: {' '.join(e.cmd)}")
    exit(1)
except Exception as e:
    print(f"Unexpected error: {e}")
    exit(1)
