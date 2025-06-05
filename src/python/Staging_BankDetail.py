from sqlalchemy import create_engine, text
import pandas as pd

# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5432/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
print (BackOffice)

with open('./sql/STG_BankDetail.sql', 'r') as file:
    query = file.read()

# Create the engine for the source DB
sourceDB = create_engine(BackOffice)

# Query and load into DataFrame
df = pd.read_sql(query, sourceDB)

print(df.head())

# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."BankDetail"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='BankDetail',            # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',          # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.BankDetail' successfully.")
except Exception as e:
    print("Error writing to table:", e)
