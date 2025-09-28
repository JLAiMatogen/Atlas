import pandas as pd
import oracledb
from sqlalchemy import create_engine
from sqlalchemy.dialects.oracle import NUMBER, VARCHAR, DATE
from decimal import Decimal
import numpy as np

# 1. Connect to PostgreSQL
pg_engine = create_engine("postgresql+psycopg2://atlas_read_all:atlasAfrica%40123%21@172.31.75.6:5432/backoffice")

# 2. Read data into a DataFrame
query = "Select * from 	backoffice.sqlmig.\"Application\" aa where \"CreateDate\" between '2024-01-01' and '2024-01-31' limit 100"
df = pd.read_sql(query, pg_engine)
df.head()

# 3. Preprocess Data
df.columns = df.columns.str.upper()  # Oracle usually stores column names in uppercase
df = df.where(pd.notnull(df), None)  # Replace NaN with None

# 4. Convert float64 columns to Decimal (to prevent FLOAT coercion)
for col in df.select_dtypes(include=["float64"]).columns:
    df[col] = df[col].apply(lambda x: Decimal(str(x)) if x is not None else None)

# 5. Generate dtype mapping
dtype_mapping = {}
for col in df.columns:
    dtype = df[col].dtype
    if dtype == "int64":
        dtype_mapping[col] = NUMBER(precision=38, scale=0)
    elif dtype == "float64":  # Should be Decimal now
        dtype_mapping[col] = NUMBER(precision=38, scale=10)
    elif dtype == "object":
        max_len = df[col].astype(str).str.len().max()
        dtype_mapping[col] = VARCHAR(int(max_len) + 10)
    elif np.issubdtype(dtype, np.datetime64):
        dtype_mapping[col] = DATE()

# 6. Oracle connection via oracledb in thick mode
#Setup to connect to Oracle DB
# Oracle Credentials
username = 'atlas'
password = 'Atlas_123'
host = 'otrsup.premipoint.co.za'
port = 1726
service_name = 'OTRSUP'

ld = '/Applications/instantclient_19_8'
# Use TNS descriptor (for SID)
AtlasTNS = f"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db-sa-03.ajenti.co.za)(PORT=1726))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTRSUP)))"

oracle_engine = create_engine(f'oracle+oracledb://@',
            thick_mode={"lib_dir": ld},
            connect_args={
                "user": username,
                "password": password,
                "dsn": AtlasTNS
            } )

# 7. Write DataFrame to Oracle
table_name = "BSD_APPLICATION"
df.to_sql(
    name=table_name,
    con=oracle_engine,
    if_exists="replace",  # or 'append'
    index=False,
    dtype=dtype_mapping
)

print("✅ Data successfully written to Oracle.")