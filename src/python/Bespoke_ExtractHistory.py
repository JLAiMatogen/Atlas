from datetime import datetime, timedelta, date
import calendar
import subprocess
import os
import sys


# Open log file
log_file_path = 'Bespoke_ExtractHistory.log'
err_log_path = 'Bespoke_ExtractHistory_Error.log'
log_file = open(log_file_path, 'w' , buffering=1)
err_log =  open(log_file_path, 'w' , buffering=1)

# Optional: Also redirect os-level stdout/stderr (for subprocesses)
os.dup2(log_file.fileno(), 1)  # stdout (fd 1)
os.dup2(log_file.fileno(), 2)  # stderr (fd 2)

# Redirect stdout and stderr
sys.stdout = log_file
sys.stderr = log_file

def generate_5_day_intervals(start_date_str, end_date_str):
  # Parse input dates
  start_date = datetime.strptime(start_date_str, "%Y-%m-%d")
  end_date = datetime.strptime(end_date_str, "%Y-%m-%d")

  intervals = []
  current_start = start_date

  while current_start <= end_date:
      current_end = min(current_start + timedelta(days=4), end_date)
      intervals.append((
          current_start.strftime("%Y-%m-%d"),
          current_end.strftime("%Y-%m-%d")
      ))
      current_start = current_end + timedelta(days=1)

  return intervals

# Get the current folder
script_dir = os.path.dirname(os.path.abspath(__file__))

# Target script path (in same folder)
target_script = os.path.join(script_dir, "Oracle_SqlScript.py")

StartDate = sys.argv[1]
EndDate = sys.argv[2]

start_date = datetime.strptime(StartDate, '%Y-%m-%d')
end_date = datetime.strptime(EndDate, '%Y-%m-%d')


#table_scripts = [
#            ("ACC_Account.sql", "BSP_ACCOUNT")
#        #  ("BSP_Application.sql", "BSP_APPLICATION_202506")
#        #, ("BSP_Client.sql", "BSP_CLIENT_202506")
#        #, ("BSP_Affordability.sql", "BSP_AFFORDABILITY_202506")
#        #, ("BSP_CreditScore.sql", "BSP_CREDITSCORE_202506")
#        #, ("BSP_Address.sql", "BSP_ADDRESS_202506")
#      ]
#
#    # Collect all the related tables
#for script_file, table_name in table_scripts:
#        subprocess.run(
#            ["python", target_script, "history", StartDate, EndDate, script_file, table_name],
#            check=True  # Raises CalledProcessError on failure
#        )


# Loop through months
current = start_date
try:
  while current <= end_date:
    year = current.year
    month = current.month

    # First and last day of the current month
    start_of_month = datetime(year, month, 1)
    last_day = calendar.monthrange(year, month)[1]
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
          ("BSP_Application.sql","BSP_APPLICATION")
        , ("BSP_Account.sql", "BSP_ACCOUNT")
        , ("BSP_Affordability.sql", "BSP_AFFORDABILITY")
        , ("BSP_CreditScore.sql", "BSP_CREDITSCORE")
        , ("BSP_Client.sql", "BSP_CLIENT")
        , ("BSP_Address.sql","BSP_ADDRESS")
      ]

    # Collect all the related tables
    for script_file, table_name in table_scripts:
            #print(f"Processing {table_name} for {month_str}... {start_of_month} .. {end_of_month}")
            subprocess.run(
                ["python", target_script, "history", str(start_of_month), str(end_of_month), script_file, table_name],
                  check=True,   # Raises CalledProcessError on failure
                  stdout=log_file,
                  stderr=log_file  
            )

    
    #Merge the data into the results table Loan
except subprocess.CalledProcessError as e:
    print(f"Error: Subprocess failed with exit code {e.returncode}. Command: {' '.join(e.cmd)}")
    log_file.close()
    exit(1)
except Exception as e:
    print(f"Unexpected error: {e}")
    log_file.close()
    exit(1)

log_file.close()