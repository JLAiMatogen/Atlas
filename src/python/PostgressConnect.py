import psycopg2
import pandas as pd

# Define connection parameters
MatogenDB = {
    "dbname": "MatogenDB",
    "user": "matogen",
    "password": "M@t0g3N!05",
    "host": "172.31.75.49",     # e.g., "localhost" or IP address
    "port": "5432"              # default PostgreSQL port
}

BackOffice = {
    "dbname": "backoffice",
    "user": "atlas_read_all",
    "password": "atlasAfrica@123!",
    "host": "172.31.75.6",  # e.g., "localhost" or IP address
    "port": "5432"          # default PostgreSQL port
}

# Create connection
try:
    conn = psycopg2.connect(**BackOffice)
    print("Connection successful.")

    # Define your SQL query
    query = "SELECT * FROM staging.bank;"
    query = 'Select * from ' \
    'staging.bank'

    with open('./sql/BadRates.sql', 'r') as file:
        query = file.read()

    print(query)
    # Load data into DataFrame
    df = pd.read_sql_query(query, conn)

    # Close connection
    conn.close()

    # Display DataFrame
    print(df.head())

except Exception as e:
    print("Error:", e)