from sqlalchemy import create_engine, text
import pandas as pd

from datetime import datetime, timedelta
import calendar
import sys

# Create connection string
MatogenDB = "postgresql+psycopg2://matogen:M%40t0g3N%2105@172.31.75.49:5432/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"
print (BackOffice)

# Define start and end date (inclusive)
start_date = datetime(2020, 1, 1)
end_date = datetime(2020, 6, 1)

# Loop through months
# Define start and end date (inclusive)
start_date = datetime(2025, 1, 1)
end_date = datetime(2025, 1, 1)

# Loop through months
current = start_date
while current <= end_date:
  with open('./sql/delta/BadRates.sql', 'r') as file:
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

  engine2 = create_engine(MatogenDB)

  # Define the SQL query
  deleteQuery = text('DELETE FROM staging."TestWrite" WHERE "OpenMonth" = :month')
  print(deleteQuery)
  # Use a connection context
  with engine2.connect() as connection:
    connection.execute(deleteQuery, {"month": month_str})
    connection.commit()  # Required for data-changing operations

  # Write DataFrame to a table in the "staging" schema
  try:
      df.to_sql(
          name='TestWrite',            # Replace with actual table name
          con=engine2,
          schema='staging',            # 🔄 Specify schema here
          if_exists='append',          # Options: 'fail', 'replace', 'append'
          index=False
      )
      print("Data written to 'staging.TestWrite' successfully.")
  except Exception as e:
      print("Error writing to table:", e)


  # Move to next month
  if month == 12:
      current = datetime(year + 1, 1, 1)
  else:
      current = datetime(year, month + 1, 1)

