from sqlalchemy import create_engine, text
import pandas as pd
import time
import subprocess
import os
import sys
from datetime import datetime, timedelta, date

sys.stdout.reconfigure(line_buffering=True)

import builtins
from datetime import datetime
# Override print globally
def print(*args, **kwargs):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    builtins.print(f"{timestamp} -", *args, **kwargs)


# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"

# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

start_time = time.time()

def run_procedure(engine, schema, procedure_name):
  """
  Run a PostgreSQL stored procedure under a specific schema.
  
  Args:
      engine: SQLAlchemy engine
      schema: Schema to set in search_path
      procedure_name: Name of the procedure to call
  """
  try:
      with engine.connect() as conn:
          print(f"Setting search_path to '{schema}' and running procedure '{procedure_name}'")
          conn.execute(text(f'SET search_path TO {schema};'))
          conn.execute(text(f'CALL "{procedure_name}"();'))
          print(f"Procedure '{procedure_name}' executed successfully")
  except Exception as e:
      print(f"Error running procedure '{procedure_name}': {e}")

run_procedure(targetDB, 'prod', 'Refresh_All_MViews')