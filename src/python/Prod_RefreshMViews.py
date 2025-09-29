from sqlalchemy import create_engine, text
import pandas as pd
import time
import subprocess
import os
import sys
from datetime import datetime, timedelta, date
import builtins

sys.stdout.reconfigure(line_buffering=True)

# Override print globally with timestamp
def print(*args, **kwargs):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    builtins.print(f"{timestamp} -", *args, **kwargs)


# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"

# Create the engine for the Target DB
targetDB = create_engine(MatogenDB)

start_time = time.time()

def run_procedure(engine, schema, procedure_name):
    """
    Run a PostgreSQL stored procedure under a specific schema,
    capturing RAISE NOTICE messages as well.
    """
    try:
        with engine.connect() as conn:
            # Access the raw psycopg2 connection to capture notices
            raw_conn = conn.connection.connection  

            def notice_handler(notice):
                # Print each RAISE NOTICE line
                print("NOTICE:", notice.strip())

            # psycopg2 connection stores notices in .notices (list)
            raw_conn.notices.clear()

            print(f"Setting search_path to '{schema}' and running procedure '{procedure_name}'")
            conn.execute(text(f'SET search_path TO {schema};'))
            conn.execute(text(f'CALL \"{procedure_name}\"();'))

            # Flush notices after procedure call
            for n in raw_conn.notices:
                print("NOTICE:", n.strip())
            raw_conn.notices.clear()

            print(f"Procedure '{procedure_name}' executed successfully")

    except Exception as e:
        print(f"Error running procedure '{procedure_name}': {e}")

run_procedure(targetDB, 'prod', 'Refresh_All_MViews')