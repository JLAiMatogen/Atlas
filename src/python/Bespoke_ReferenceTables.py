from sqlalchemy.dialects.oracle import NUMBER, VARCHAR, DATE, FLOAT as ORACLE_FLOAT
from decimal import Decimal
import numpy as np
from sqlalchemy import create_engine, text, Float
import pandas as pd
import time
import os
import oracledb

# Create connection string
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
print (BackOffice)

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

# Create the engine for the source DB
sourceDB = create_engine(BackOffice)

#Oracle Connection
oracleDB = create_engine(f'oracle+oracledb://@',
            thick_mode={"lib_dir": ld},
            connect_args={
                "user": username,
                "password": password,
                "dsn": AtlasTNS
            } )

# Tables to truncate
tables = ['BSP_BRANCH'
        , 'BSP_PROVINCE'
        , 'BSP_MARITALSTATUS'
        , 'BSP_ETHNICITY'
        , 'BSP_COUNTRY'
        , 'BSP_PROPERTYOWNERSHIP'
        , 'BSP_CANCELREASON'
        , 'BSP_REGION'
        , 'BSP_PRODUCTS'
]
#tables = ['BSP_BRANCH']

with oracleDB.connect() as connection:
    for table in tables:
        print(f"Truncating table: {table}")
        try:
          connection.execute(text(f'TRUNCATE TABLE {table}'))
        except Exception as e:
          print(f"Error truncateing {table}", e)
    
    print("All tables truncated successfully.")

#Extract Refernce Tables
source_target_tables = [
      ( 'backoffice.sqlmig."Province"' , "BSP_PROVINCE" )
    , ( 'backoffice.sqlmig."Branch"' , "BSP_BRANCH" )
    , ( 'backoffice.sqlmig."MaritalStatus"' , "BSP_MARITALSTATUS")
    , ( 'backoffice.sqlmig."Ethnicity"' , "BSP_ETHNICITY")
    , ( 'backoffice.sqlmig."Country"' , "BSP_COUNTRY")
    , ( 'backoffice.sqlmig."PropertyOwnership"' , "BSP_PROPERTYOWNERSHIP")
    , ( 'backoffice.sqlmig."CancelReason"' , "BSP_CANCELREASON")
    , ( 'backoffice.public."Region"' , "BSP_REGION")
    , ( 'backoffice.public."PRD_Products"' , "BSP_PRODUCTS")
    , ( 'backoffice.sqlmig."Industry"' , "BSP_INDUSTRY" )
]
#source_target_tables = [ ( 'backoffice.sqlmig."Branch"' , "BSP_BRANCH" ) ]

# Default length for VARCHAR if no max length can be determined
DEFAULT_VARCHAR_LEN = 128

print('Start Extracting Refernce Data')
for source_table, target_table in source_target_tables:
        print(source_table,target_table)
        start_time = time.time()
        
        query = (f'Select a.* from {source_table} a' )
        if source_table == 'backoffice.public."Region"':
            query = 'select "RegionId", "ProfileId","LegacyRegionCode","Description","CreatedDT","PersonId" from public."Region"'
        elif source_table == 'backoffice.public."PRD_Products"':
            query = 'select "ProductId", "ProductName","ProductDisplayName","Description" from public."PRD_Products"'

        query = text(query)

        df = pd.read_sql(query, sourceDB)
        df.columns = df.columns.str.upper()  # Oracle usually stores column names in uppercase

        dtype_mapping = {}
        for col in df.columns:
            dtype = df[col].dtype
            if dtype == "int64":
                dtype_mapping[col] = NUMBER(precision=38, scale=0)
            elif dtype == "bigserial":
                dtype_mapping[col] = NUMBER(precision=38, scale=0)
            elif dtype == "float64":
                dtype_mapping[col] = NUMBER(precision=38, scale=10)
                #dtype_mapping[col] = Float(precision=53).with_variant(ORACLE_FLOAT(binary_precision=126), 'oracle')
            elif dtype == "object":
                # Get max length of string values in column
                max_len = df[col].astype(str).str.len().max()
                if pd.isna(max_len):
                    max_len = DEFAULT_VARCHAR_LEN
                dtype_mapping[col] = VARCHAR(int(max_len) + 10)
            elif np.issubdtype(dtype, np.datetime64):
                dtype_mapping[col] = DATE()
            
            #print(col,dtype,dtype_mapping[col])

        # Write DataFrame to a table in the "staging" schema
        try:
            df.to_sql(
                name=target_table,          # Replace with actual table name
                con=oracleDB,
                schema='atlas',               # 🔄 Specify schema here
                if_exists='append',           # Options: 'fail', 'replace', 'append'
                index=False
            )
            print(f"Data written to {target_table} successfully.")
        except Exception as e:
            print("Error writing to table:", e)

        end_time = time.time()
        elapsed_time = end_time - start_time
        print("Execution time:", elapsed_time, "seconds")

exit()


# Query and load into DataFrame from ACC_LoanStateReason
with open('./sql/history/BSP_Province.sql', 'r') as file:
    query = file.read()
    df = pd.read_sql(query, sourceDB)
    df.columns = df.columns.str.upper()  # Oracle usually stores column names in uppercase

print(df.head())

end_time = time.time()
elapsed_time = end_time - start_time
# Output
print("Execution time:", elapsed_time, "seconds")

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='BSP_PROVINCE',          # Replace with actual table name
        con=oracleDB,
        schema='atlas',               # 🔄 Specify schema here
        if_exists='append',           # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'atlas.BSP_Province' successfully.")
except Exception as e:
    print("Error writing to table:", e)


print('Start MaritalStatus')
start_time = time.time()

# Query and load into DataFrame from ACC_LoanStateReason
with open('./sql/history/BSP_MaritalStatus.sql', 'r') as file:
    query = file.read()
    df = pd.read_sql(query, sourceDB)
    df.columns = df.columns.str.upper()  # Oracle usually stores column names in uppercase
    
print(df.head())

end_time = time.time()
elapsed_time = end_time - start_time
# Output
print("Execution time:", elapsed_time, "seconds")

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='BSP_MARITALSTATUS',          # Replace with actual table name
        con=oracleDB,
        schema='atlas',               # 🔄 Specify schema here
        if_exists='append',           # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'atlas.BSP_MaritalStatus' successfully.")
except Exception as e:
    print("Error writing to table:", e)

print('Start Branch')
start_time = time.time()

# Query and load into DataFrame from ACC_LoanStateReason
with open('./sql/history/BSP_Branch.sql', 'r') as file:
    query = file.read()
    df = pd.read_sql(query, sourceDB)
print(df.head())


#Do Data type mapping# 
# 3. Preprocess Data
df.columns = df.columns.str.upper()  # Oracle usually stores column names in uppercase
df = df.where(pd.notnull(df), None)  # Replace NaN with None

# 4. Convert float64 columns to Decimal (to prevent FLOAT coercion)
for col in df.select_dtypes(include=["float64"]).columns:
    df[col] = df[col].apply(lambda x: Decimal(str(x)) if x is not None else None)


# 5. Generate dtype mapping
dtype_mapping = {}
for col in df.columns:
    dtype = df[col].dtype
    if dtype == "int64":
        dtype_mapping[col] = NUMBER(precision=38, scale=0)
    elif dtype == "float64":  # Should be Decimal now
        dtype_mapping[col] = NUMBER(precision=38, scale=10)
    elif dtype == "object":
        max_len = df[col].astype(str).str.len().max()
        dtype_mapping[col] = VARCHAR(int(max_len) + 10)
    elif np.issubdtype(dtype, np.datetime64):
        dtype_mapping[col] = DATE()

print(dtype_mapping)

end_time = time.time()
elapsed_time = end_time - start_time
# Output
print("Execution time:", elapsed_time, "seconds")

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='BSP_BRANCH',          # Replace with actual table name
        con=oracleDB,
        schema='atlas',               # 🔄 Specify schema here
        if_exists='append',           # Options: 'fail', 'replace', 'append'
        index=False,
        dtype=dtype_mapping
    )
    print("Data written to 'atlas.BSP_BRANCH' successfully.")
except Exception as e:
    print("Error writing to table:", e)