#This process loads the file that contains bureau information for the period 20240101 - 20241231

import pandas as pd
import numpy as np
import openpyxl

from sqlalchemy import create_engine, text

# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"

# Creat the engine for the Target DB
targetDB = create_engine(MatogenDB)

# Define the SQL query
try:
  deleteQuery = text('DELETE FROM staging."BureauSelectionAndOffers"')
  print(deleteQuery)

  # Use a connection context
  with targetDB.connect() as connection:
    connection.execute(deleteQuery)
    connection.commit()  # Required for data-changing operations
except Exception as e:
  print("Error Deleting the data from the BureauSelectionAndOffers table:", e)

BureauData = pd.read_excel("../../ClientData/BureauSelectionAndOffers Klay_Brett File 18.02.2025.xlsx", sheet_name='BureauSelectionAndOffers')

# Write DataFrame to a table in the "staging" schema
try:
    BureauData.to_sql(
        name='BureauSelectionAndOffers',            # Replace with actual table name
        con=targetDB,
        schema='staging',            # 🔄 Specify schema here
        if_exists='append',          # Options: 'fail', 'replace', 'append'
        index=False
    )
    print("Data written to 'staging.BureauSelectionAndOffers' successfully.")
except Exception as e:
    print("Error writing to table BureauSelectionAndOffers:", e)