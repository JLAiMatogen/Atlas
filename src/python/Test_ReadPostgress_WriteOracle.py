from sqlalchemy import create_engine, text
import pandas as pd

from datetime import datetime, timedelta
import calendar
import sys

import datetime

#Setup to connect to Oracle DB
import os
import oracledb

# Example credentials
username = 'atlas'
password = 'Atlas_123'
host = 'otrsup.premipoint.co.za'
port = 1726
service_name = 'OTRSUP'

ld = '/Applications/instantclient_19_8'
# Use TNS descriptor (for SID)
tns = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db-sa-03.ajenti.co.za)(PORT=1726))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTRSUP)))"

ct = datetime.datetime.now()
print(ct)

# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5432/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
AtlasOracle = "oracle+oracledb://atlas:Atlas_123@otrsup.premipoint.co.za:1726/?sid=OTRSUP"

#/Users/johan/Workspace/Matogen/Atlas/src/python/sql/BureauRespone.sql
with open('./sql/BureauRespone.sql', 'r') as file:
  query = file.read()
query = text(query)

engine = create_engine(BackOffice)

print('Start executing the query')
ct = datetime.datetime.now()
print(ct)

# Execute it using SQLAlchemy session or connection
#with engine.connect() as conn:
conn = engine.connect()
result = conn.execute(query)
print('Results found')
df = pd.DataFrame(result.fetchall(), columns=result.keys())


engine2 = create_engine(f'oracle+oracledb://@',
            thick_mode={"lib_dir": ld},
            connect_args={
                "user": username,
                "password": password,
                "dsn": tns
            } )


# Define the SQL query
#deleteQuery = text('DELETE FROM staging."TestWrite" WHERE "OpenMonth" = :month')
#print(deleteQuery)
# Use a connection context
with engine2.connect() as connection:
    #connection.execute(deleteQuery, {"month": month_str})
    #connection.commit()  # Required for data-changing operations

    # Write DataFrame to a table in the "staging" schema
    try:
        df.columns = df.columns.str.upper()
        df.to_sql(
            name='STG_BUREAURESPONSE',     # Replace with actual table name
            con=engine2,
            schema='atlas',            # 🔄 Specify schema here
            if_exists='append',        # Options: 'fail', 'replace', 'append'
            index=False
        )
        print("Data written to 'STG_BUREAURESPONSE' successfully.")
    except Exception as e:
        print("Error writing to table:", e)

# Query and load into DataFrame
#df = pd.read_sql(query, engine)

print('Done with the process')
ct = datetime.datetime.now()
print(ct)

print(df.head())