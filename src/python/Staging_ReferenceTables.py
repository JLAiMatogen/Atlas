from sqlalchemy import create_engine, text
import pandas as pd

# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5432/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
print (BackOffice)


# Create the engine for the source DB
sourceDB = create_engine(BackOffice)

# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

print('Start ACC_LoanStateReason')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."ACC_LoanStateReason"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from ACC_LoanStateReason
with open('./sql/STG_ACC_LoanStateReason.sql', 'r') as file:
    query = file.read()
    df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='ACC_LoanStateReason',            # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',          # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.ACC_LoanStateReason' successfully.")
except Exception as e:
    print("Error writing to table:", e)

print('Start ACC_PeriodFrequency')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."ACC_PeriodFrequency"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from ACC_PeriodFrequency
with open('./sql/STG_ACC_PeriodFrequency.sql', 'r') as file:
    query = file.read()
df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='ACC_PeriodFrequency',  # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',          # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.ACC_PeriodFrequency' successfully.")
except Exception as e:
    print("Error writing to table:", e)


print('Start Branch')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."Branch"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from Branch
with open('./sql/STG_Branch.sql', 'r') as file:
    query = file.read()
df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='Branch',              # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',         # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.Branch' successfully.")
except Exception as e:
    print("Error writing to table:", e)

print('Start PaymentModes')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."PaymentModes"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from PaymentModes
with open('./sql/STG_PaymentModes.sql', 'r') as file:
    query = file.read()
df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='PaymentModes',              # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',         # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.PaymentModes' successfully.")
except Exception as e:
    print("Error writing to table:", e)

print('Start Bank')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."Bank"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from Bank
with open('./sql/STG_Bank.sql', 'r') as file:
    query = file.read()
df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='Bank',              # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',         # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.Bank' successfully.")
except Exception as e:
    print("Error writing to table:", e)

print('Start PRD_Products')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."PRD_Products"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from PRD_Products
with open('./sql/STG_PRD_Products.sql', 'r') as file:
    query = file.read()
df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='PRD_Products',              # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',         # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.PRD_Products' successfully.")
except Exception as e:
    print("Error writing to table:", e)

print('Start PER_Person')
# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."PER_Person"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the target table:", e)

# Query and load into DataFrame from PER_Person
with open('./sql/STG_PER_Person.sql', 'r') as file:
    query = file.read()
df = pd.read_sql(query, sourceDB)
print(df.head())

# Write DataFrame to a table in the "staging" schema
try:
    df.to_sql(
        name='PER_Person',              # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',         # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.PER_Person' successfully.")
except Exception as e:
    print("Error writing to table:", e)