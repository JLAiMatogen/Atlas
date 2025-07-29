from sqlalchemy import create_engine, text
import pandas as pd

#Setup to connect to Oracle DB
import os
import oracledb

# Oracle Credentials
username = 'atlas'
password = 'Atlas_123'
host = 'otrsup.premipoint.co.za'
port = 1726
service_name = 'OTRSUP'

ld = '/Applications/instantclient_19_8'
# Use TNS descriptor (for SID)
AtlasTNS = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db-sa-03.ajenti.co.za)(PORT=1726))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTRSUP)))"


# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
print (BackOffice)


# Create the engine for the source DB
sourceDB = create_engine(BackOffice)

# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

print('Start STG_BureauResponse')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."STG_BureauResponse"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from STG_BureauResponse
print('Collect the data')
with open('./sql/delta/BureauRespone.sql', 'r') as file:
    query = file.read()
    #This query contains special charcaters that needs to be converted to text before the enige can read the data
    query = text(query)
    df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='STG_BureauResponse',            # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',          # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.STG_BureauResponse' successfully.")
except Exception as e:
    print("Error writing to table:", e)


#currently also write the data to the Oracle staging area
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
    df.to_sql(
        name='STG_BUREAURESPONSE',            # Replace with actual table name
        con=oracleDB,
        schema='atlas',            # 🔄 Specify schema here
        if_exists='append',          # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'Oracle DB staging.STG_BUREAURESPONSE' successfully.")
except Exception as e:
    print("Error writing to table:", e)