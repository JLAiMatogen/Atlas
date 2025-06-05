from sqlalchemy import create_engine, text
from urllib.parse import quote_plus

#Setup to connect to Oracle DB
import os
import oracledb
ld = '/Applications/instantclient_19_8'
# Use TNS descriptor (for SID)
tns = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db-sa-03.ajenti.co.za)(PORT=1726))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTRSUP)))"


# Example credentials
username = 'atlas'
password = 'Atlas_123'
host = 'otrsup.premipoint.co.za'
port = 1726
service_name = 'OTRSUP'

# Encode special characters in password
from urllib.parse import quote_plus
password_encoded = quote_plus(password)


# Build SQLAlchemy URL
#db_url = f"oracle+oracledb://{username}:{password_encoded}@/?dsn={quote_plus(tns)}"
#db_url = "oracle+oracledb://atlas:Atlas_123@otrsup.premipoint.co.za:1726/?SID=OTRSUP"

# Create engine
#engine = create_engine(db_url)

 
# Test connection
# Connect and test
try:
    engine = create_engine(f'oracle+oracledb://@',
                       thick_mode={"lib_dir": ld},
                       connect_args={
                           "user": username,
                           "password": password,
                           "dsn": tns
                       }
         )
    with engine.connect() as conn:
        result = conn.execute(text("SELECT sysdate FROM dual"))
        print("Connection successful!")
        for row in result:
            print("Result:", row)
except Exception as e:
    print("Connection failed.")
    print("Error:", e)