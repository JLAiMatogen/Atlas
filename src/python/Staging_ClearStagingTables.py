from sqlalchemy import create_engine, text
import psycopg

# Create connection string
MatogenDB = "postgresql+psycopg://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"
BackOffice = "postgresql+psycopg://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
print (BackOffice)


# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

def handle_notice(notice):
    print("NOTICE:", notice.message.strip())

with targetDB.connect().execution_options(isolation_level="AUTOCOMMIT") as conn:
    raw_conn = conn.connection.driver_connection
    raw_conn.add_notice_handler(handle_notice)

    conn.execute(text("SET client_min_messages TO NOTICE"))
    conn.execute(text("CALL staging.\"Table_Cleanup\"()"))