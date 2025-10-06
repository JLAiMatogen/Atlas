#!/bin/bash
# Usage: ./load_sql.sh <sql_file> <schema>

HOST="172.31.75.49"
PORT="5832"
USER="matogen"
DBNAME="MatogenDB"
SQL_FILE="$1"
SCHEMA="$2"

# Set password
export PGPASSWORD="M@t0g3N!05"

# Run the SQL file with search_path set
echo "⏳ Loading $SQL_FILE into $DBNAME.$SCHEMA ..."

psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DBNAME" <<EOF
SET search_path TO $SCHEMA;
\i $SQL_FILE
EOF

#psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DBNAME" \
#  --set=search_path="$SCHEMA" -f "$SQL_FILE"

echo "✅ $SQL_FILE loaded successfully into schema $SCHEMA"
