from sqlalchemy import create_engine, text
import pandas as pd
import time
import subprocess
import os
import sys
from datetime import datetime, timedelta, date

import builtins
from datetime import datetime
# Override print globally
def print(*args, **kwargs):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    builtins.print(f"{timestamp} -", *args, **kwargs)


# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"

# Create the engine for the source DB
sourceDB = create_engine(BackOffice)

# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

start_time = time.time()

# Collect all the related tables
table_scripts = [
    ("ACC_LoanStateReason.sql", "ACC_LoanStateReason", ['Code']),
    ("ACC_PeriodFrequency.sql", "ACC_PeriodFrequency", ['PeriodFrequencyId']),
    ("Branch.sql", "Branch", ['BranchId']),
    ("PaymentModes.sql", "PaymentModes", ['PaymentModeId']),
    ("Bank.sql", "Bank", ['BankId']),
    ("PRD_Products.sql", "PRD_Products", ['ProductId']),
    ("ACC_PaymentStatus.sql", "ACC_PaymentStatus", ['PaymentStatusId']),
    ("Province.sql", "Province", ['ProvinceId']),
    ("MaritalStatus.sql", "MaritalStatus", ['MaritalStatusId']),
    ("Languages.sql", "Languages", ['LanguagesId']),
    ("Country.sql", "Country", ['CountryId'])
    ]

# Get the current folder
script_dir = os.path.dirname(os.path.abspath(__file__))

# Target script path (in same folder)
target_script = os.path.join(script_dir, "Staging_SqlScript.py")

# Collect all the related tables
for script_file, table_name, key_columns in table_scripts:
    subprocess.run(
        ["python", target_script, "reference", "", "",script_file, table_name] + key_columns,
        check=True
    )