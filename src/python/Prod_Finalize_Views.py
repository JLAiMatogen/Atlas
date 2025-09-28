# Usage: ./Staging_SqlScript.py {history/delta} {2024-01-01} {2024-01-31} {ACC_Debitorder.sql} {ACC_Debitorder}
# When history all parameters are compulsory
# When deltae the start and end date can be ommitted.

from sqlalchemy import create_engine, text
import psycopg2
import pandas as pd
import os
import sys
import time

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

# Create the engine for the source DB
sourceDB = create_engine(BackOffice)
# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

start_time = time.time()

print('Start the update of the Materialized views!')
# 1. Execute procedure to finalize the materialized views.
with targetDB.connect().execution_options(isolation_level="AUTOCOMMIT") as conn:
  raw_conn = conn.connection.driver_connection
  # Create a cursor
  cur = raw_conn.cursor()

  # Call the procedure
  cur.execute("""
      CALL prod."Refresh_All_MViews"();
  """)

  # Commit if the procedure modifies data
  conn.commit()

  # Cleanup
  cur.close()
  conn.close()

  print(f"Materilized Views updated successfuly.")

end_time = time.time()
elapsed_time = end_time - start_time
print("Execution time:", elapsed_time, "seconds")