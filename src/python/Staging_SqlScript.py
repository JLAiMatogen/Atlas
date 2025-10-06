# Usage: ./Staging_SqlScript.py {history/delta} {2024-01-01} {2024-01-31} {ACC_Debitorder.sql} {ACC_Debitorder}
# When history all parameters are compulsory
# When deltae the start and end date can be ommitted.

from sqlalchemy import create_engine, text
import psycopg2
import pandas as pd
import os
import sys
import time

sys.stdout.reconfigure(line_buffering=True)

import builtins
from datetime import datetime
# Override print globally
def print(*args, **kwargs):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    builtins.print(f"{timestamp} -", *args, **kwargs)

def handle_notice(notice):
  print("NOTICE:", notice.message.strip())

# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"

mode = sys.argv[1]
sqlScript = sys.argv[4]
tablename = sys.argv[5]
keyColumns = sys.argv[6:]

print(f"Start Extracting {mode} for {tablename} with keys as {keyColumns}")

if mode.lower() == "delta":
  with open('../src/sql/delta/' + sqlScript, 'r') as file:
    query = file.read()
elif mode.lower() == "reference":
  with open('../src/sql/reference/' + sqlScript, 'r') as file:
    query = file.read()
else:
  with open('../src/sql/history/' + sqlScript, 'r') as file:
    query = file.read()
    StartDate = sys.argv[2]
    EndDate = sys.argv[3]

    query = query.replace("{STARTDATE}", StartDate)
    query = query.replace("{ENDDATE}",  EndDate)
  
# Create the engine for the source DB
sourceDB = create_engine(BackOffice)
# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

start_time = time.time()
# Query and load into DataFrame
query = text(query)
print("Run Query to extract data [",query,"]")
df = pd.read_sql(query, sourceDB)

end_time = time.time()
elapsed_time = end_time - start_time
# Output
print("Execution time:", elapsed_time, "seconds")
print(df.head())

# 1. Truncate table first
try:
    with targetDB.connect() as conn:
        conn.execute(text(f"TRUNCATE TABLE staging.\"{tablename}\""))
        conn.commit()  # Necessary if you're using a transactional DB (e.g., PostgreSQL)
        print(f"Table staging.{tablename} truncated successfully.")
except Exception as e:
    print("Error truncating table:", e)


# 2. Write DataFrame to a table in the "staging" schema    
print(f"Start writing data to staging.{tablename} in chunks of 500,000 rows.")

try:
    df.to_sql(
        name=tablename,               # Replace with actual table name
        con=targetDB,
        schema='staging',             # 🔄 Specify schema here
        if_exists='append',           # Options: 'fail', 'replace', 'append'
        index=False,
        chunksize=500_000             # ✅ Write in blocks of 500,000 rows
    )
    print(f"✅ Data written to staging.{tablename} successfully in chunks.")
except Exception as e:
    print("❌ Error writing to table:", e)

# 3. Merge the Staging data into the prod schema table on the specified key.
with targetDB.connect().execution_options(isolation_level="AUTOCOMMIT") as conn:
  raw_conn = conn.connection.driver_connection
  # Create a cursor
  cur = raw_conn.cursor()

  # Prepare input parameters
  source_schema = 'staging'
  source_table = tablename
  target_schema = 'prod'
  target_table = tablename
  key_columns = keyColumns  # must be passed as array

  # Call the procedure
  cur.execute("""
      CALL prod."Merge_Tables_Auto"(%s, %s, %s, %s, %s);
  """, (source_schema, source_table, target_schema, target_table, key_columns))

  # Commit if the procedure modifies data
  conn.commit()

  # Cleanup
  cur.close()
  conn.close()

  print(f"Data written to prod.{tablename} successfully.")