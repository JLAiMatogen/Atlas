import time
from datetime import datetime
from sqlalchemy import create_engine, text
import sys
import builtins

sys.stdout.reconfigure(line_buffering=True)

# Override print globally with timestamp
def print(*args, **kwargs):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    builtins.print(f"{timestamp} -", *args, **kwargs)

def refresh_all_mviews(connection_string: str, schema: str = None):
    """
    Refresh a list of materialized views in PostgreSQL with timing and error handling.

    Args:
        connection_string (str): SQLAlchemy/Postgres connection string
        schema (str, optional): Schema name. If None, defaults to current schema.
    """
    engine = create_engine(connection_string)

    views_to_refresh = [
        "XDS_CusomerDetailsLog_MV",
        "ACC_Client_IDNumber_Summary",
        "ACC_DebitOrder_Latest",
        "Account_BadRate_Indicators",
        "ACC_PaymentStatusHistory_Latest",
        "Account_Detail_MV",
        "Cumulative_Bad_Rates_MV"
    ]

    with engine.begin() as conn:
        # if schema is not given, fetch current_schema()
        if schema is None:
            schema = 'dev'

        print(f"Setting search_path to '{schema}'")
        conn.execute(text(f'SET search_path TO {schema};'))

        t_start = time.time()
        print(f"🔄 Refreshing materialized views for schema '{schema}' at {datetime.now()}")

        for view in views_to_refresh:
            print(f"✅ Refresh {schema}.{view} ")
            try:
                t_step = time.time()
                sql = f'REFRESH MATERIALIZED VIEW CONCURRENTLY "{schema}"."{view}"'
                conn.execute(text(sql))
                elapsed = round(time.time() - t_step, 2)
                print(f"✅ {schema}.{view} refreshed in {elapsed} seconds")
            except Exception as e:
                print(f"❌ Error refreshing {schema}.{view}: {e}")
                raise  # rethrow exception if you want to stop at first error

        total_elapsed = round(time.time() - t_start, 2)
        print(f"🎉 Refresh complete at {datetime.now()} in {total_elapsed} seconds")

MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"

refresh_all_mviews(MatogenDB , 'prod')