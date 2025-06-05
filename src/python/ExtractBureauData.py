from sqlalchemy import create_engine, text
import pandas as pd

from datetime import datetime, timedelta, date
import calendar
import sys

import datetime

#Setup to connect to Oracle DB
import os
import oracledb


def get_week_ranges(year):
    first_day = date(year, 5, 14)
    # Find the first Monday of the year
    start = first_day if first_day.weekday() == 0 else first_day + timedelta(days=(7 - first_day.weekday()))

    while start.year <= year:
        end = start + timedelta(days=6)  # Monday to Sunday
        iso_year, iso_week, _ = start.isocalendar()
        
        if iso_year == year or end.year == year:
            yield iso_year, iso_week, start, end
        
        start += timedelta(days=7)

# Example credentials
username = 'atlas'
password = 'Atlas_123'
host = 'otrsup.premipoint.co.za'
port = 1726
service_name = 'OTRSUP'

ld = '/Applications/instantclient_19_8'
# Use TNS descriptor (for SID)
AtlasTNS = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db-sa-03.ajenti.co.za)(PORT=1726))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTRSUP)))"

ct = datetime.datetime.now()
print(ct)

# Create connection string
MatogenDB = "postgresql+psycopg2://x:M%40t0g3N%2105@172.31.75.49:5432/MatogenDB"
BackOffice = "postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice"


#Setuo Db Engines
engine = create_engine(BackOffice)

engine2 = create_engine(f'oracle+oracledb://@',
            thick_mode={"lib_dir": ld},
            connect_args={
                "user": username,
                "password": password,
                "dsn": AtlasTNS
            } )

for y, w, start_date, end_date in get_week_ranges(2025):
    with open('./sql/BureauRespone.sql', 'r') as file:
        sql_template = file.read()
        start_date_str = str(start_date)
        end_date_str = str(end_date)
        
        sql_template = sql_template.replace("{STARTDATE}", start_date_str)
        sql_template = sql_template.replace("{ENDDATE}",  end_date_str)
        sql_template = text(sql_template)
        print(start_date_str , end_date_str)



    # Execute it using SQLAlchemy session or connection
    #with engine.connect() as conn:
    conn = engine.connect()
    result = conn.execute(sql_template)
    print('Results found')
    df = pd.DataFrame(result.fetchall(), columns=result.keys())

    #Define the SQL query
    #deleteQuery = text('DELETE FROM staging."TestWrite" WHERE "OpenMonth" = :month')
    #print(deleteQuery)

    # Use a connection context
    with engine2.connect() as connection:
        #connection.execute(deleteQuery, {"month": month_str})
        #connection.commit()  # Required for data-changing operations

        # Write DataFrame to a table in the "staging" schema
        df.columns = df.columns.str.upper()
        try:
            df.to_sql(
                name='STG_BUREAURESPONSE',     # Replace with actual table name
                con=engine2,
                schema='atlas',            # 🔄 Specify schema here
                if_exists='append',        # Options: 'fail', 'replace', 'append'
                index=False
            )
            print("Data written to 'STG_BUREAURESPONSE' successfully.")
        except Exception as e:
            print("Error writing to table:", e)

print('Done with the process')
ct = datetime.datetime.now()
print(ct)