from sqlalchemy.dialects.oracle import NUMBER
from sqlalchemy import create_engine, text
from decimal import Decimal
import re

import pandas as pd
import sys
import time
import math
import os
import oracledb

import pandas as pd
import oracledb
from sqlalchemy import create_engine
from sqlalchemy.dialects.oracle import NUMBER, VARCHAR, DATE
from decimal import Decimal
import numpy as np

# Create connection string to BackOffice
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"

#Setup to connect to Oracle DB
# Oracle Credentials
username = 'atlas'
password = 'Atlas_123'
host = 'otrsup.premipoint.co.za'
port = 1726
service_name = 'OTRSUP'

ld = '/Applications/instantclient_19_8'
# Use TNS descriptor (for SID)
AtlasTNS = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db-sa-03.ajenti.co.za)(PORT=1726))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTRSUP)))"

mode = sys.argv[1]
sqlScript = sys.argv[4]
tablename = sys.argv[5]

print(mode , tablename)

if mode.lower() == "delta":
  with open('./sql/delta/' + sqlScript, 'r') as file:
    query = file.read()
else:
  with open('./sql/history/' + sqlScript, 'r') as file:
    query = file.read()
    StartDate = sys.argv[2]
    EndDate = sys.argv[3]

    query = query.replace("{STARTDATE}", StartDate)
    query = query.replace("{ENDDATE}",  EndDate)

    print(f"Dates Received {StartDate} .. {EndDate}")
    
# Create the engine for the source DB
sourceDB = create_engine(BackOffice)

start_time = time.time()
# Query and load into DataFrame
query = text(query)
df = pd.read_sql(query, sourceDB)

end_time = time.time()
elapsed_time = end_time - start_time
# Output
print("Execution time:", elapsed_time, "seconds")

print(df.head())

#Do Data type mapping# 
# 3. Preprocess Data
df.columns = df.columns.str.upper()  # Oracle usually stores column names in uppercase
df = df.where(pd.notnull(df), None)  # Replace NaN with None

# 4. Convert float64 columns to Decimal (to prevent FLOAT coercion)
for col in df.select_dtypes(include=["float64"]).columns:
    df[col] = df[col].apply(lambda x: Decimal(str(x)) if x is not None else None)


# 5. Generate dtype mapping
#dtype_mapping = {}
#for col in df.columns:
#    dtype = df[col].dtype
#    if dtype == "int64":
#        dtype_mapping[col] = NUMBER(precision=38, scale=0)
#    elif dtype == "float64":  # Should be Decimal now
#        dtype_mapping[col] = NUMBER(precision=38, scale=10)
#    elif dtype == "object":
#        max_len = df[col].astype(str).str.len().max()
#        dtype_mapping[col] = VARCHAR(int(max_len) + 10)
#    elif np.issubdtype(dtype, np.datetime64):
#        dtype_mapping[col] = DATE()

# Default length for VARCHAR if no max length can be determined
DEFAULT_VARCHAR_LEN = 128

dtype_mapping = {}
for col in df.columns:
    dtype = df[col].dtype
    if dtype == "int64":
        dtype_mapping[col] = NUMBER(precision=38, scale=0)
    elif dtype == "float64":
        dtype_mapping[col] = NUMBER(precision=38, scale=10)
    elif dtype == "object":
        # Get max length of string values in column
        max_len = df[col].astype(str).str.len().max()
        if pd.isna(max_len):
            max_len = DEFAULT_VARCHAR_LEN
        dtype_mapping[col] = VARCHAR(int(max_len) + 10)
    elif np.issubdtype(dtype, np.datetime64):
        dtype_mapping[col] = DATE()

print(dtype_mapping)
#currently also write the data to the Oracle staging area
print("Write data to Oracle")

oracleDB = create_engine(f'oracle+oracledb://@',
            thick_mode={"lib_dir": ld},
            connect_args={
                "user": username,
                "password": password,
                "dsn": AtlasTNS
            } )

# Write DataFrame to a table in the "staging" schema
try:
    df.columns = df.columns.str.upper()

    # Define the batch size
    batch_size = 20000
    # Calculate the number of batches
    num_batches = math.ceil(len(df) / batch_size)

    
    for i in range(num_batches):
        start_idx = i * batch_size
        end_idx = min((i + 1) * batch_size, len(df))
        
        batch_df = df.iloc[start_idx:end_idx]
        
        batch_df.to_sql(
            name=tablename,  # Replace with actual table name
            con=oracleDB,
            schema='atlas',          # Replace with your schema
            if_exists='append',      # Options: 'fail', 'replace', 'append'
            index=False,
            dtype=dtype_mapping
        )
        
        print(f"Batch {i+1}/{num_batches} written successfully.")


    print(f"All data written to Oracle DB {tablename} successfully.")
except Exception as e:
    print("Error writing to table:", e)