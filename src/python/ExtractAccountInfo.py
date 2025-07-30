from sqlalchemy import create_engine, text
import pandas as pd

from datetime import datetime, timedelta, date
import calendar
import sys

#Setup to connect to Oracle DB
import os
import oracledb

# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5832/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
print (BackOffice)

# Example credentials
username = 'atlas'
password = 'Atlas_123'
host = 'otrsup.premipoint.co.za'
port = 1726
service_name = 'OTRSUP'

ld = '/Applications/instantclient_19_8'
# Use TNS descriptor (for SID)
AtlasTNS = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db-sa-03.ajenti.co.za)(PORT=1726))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTRSUP)))"


# Define start and end date (inclusive)
start_date = datetime(2024, 9, 1)
end_date = datetime(2025, 6, 30)


# Loop through months
current = start_date
while current <= end_date:
  with open('./sql/history/BadRates.sql', 'r') as file:
        query = file.read()

  year = current.year
  month = current.month

  # First and last day of the current month
  start_of_month = datetime(year, month, 1)
  last_day = calendar.monthrange(year, month)[1]
  end_of_month = datetime(year, month, last_day)

  # Format Month without dash
  month_str = f"{year}{month:02}"  # e.g., "202001"
        
  # Print result
  print(f"Month: {month_str}, StartDate: {start_of_month.date()}, EndDate: {end_of_month.date()}")

  engine = create_engine(BackOffice)

  # Replace values
  start_of_month_str = str(start_of_month.date())
  end_of_month_str = str(end_of_month.date())
  print(start_of_month_str , end_of_month_str)

  query = query.replace("{STARTDATE}", start_of_month_str)
  query = query.replace("{ENDDATE}",  end_of_month_str)

  # Query and load into DataFrame
  df = pd.read_sql(query, engine)

  print(df.head())

  engine2 = create_engine(f'oracle+oracledb://@',
            thick_mode={"lib_dir": ld},
            connect_args={
                "user": username,
                "password": password,
                "dsn": AtlasTNS
            } )

  # Define the SQL query
  #deleteQuery = text('DELETE FROM staging."TestWrite" WHERE "OpenMonth" = :month')
  #print(deleteQuery)
  # Use a connection context
  #with engine2.connect() as connection:
  #  connection.execute(deleteQuery, {"month": month_str})
  #  connection.commit()  # Required for data-changing operations

  # Write DataFrame to a table in the "staging" schema
  try:
      df.columns = df.columns.str.upper()
      df.to_sql(
          name='STG_ACCOUNTINFO',            # Replace with actual table name
          con=engine2,
          schema='atlas',            # 🔄 Specify schema here
          if_exists='append',          # Options: 'fail', 'replace', 'append'
          index=False
      )
      print("Data written to 'staging.STG_ACCOUNTINFO' successfully.")
  except Exception as e:
      print("Error writing to table:", e)


  # Move to next month
  if month == 12:
      current = datetime(year + 1, 1, 1)
  else:
      current = datetime(year, month + 1, 1)

