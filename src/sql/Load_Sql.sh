#!/bin/bash
# Usage: ./load_sql.sh <sql_file> <schema>

HOST="172.31.75.49"
PORT="5832"
USER="matogen"
DBNAME="MatogenDB"
SQL_FILE="$1"
#SCHEMA="$2"
SCHEMA="${2:-dev}"

# Set password
export PGPASSWORD="M@t0g3N!05"

# Run the SQL file with search_path set
echo "⏳ Loading $SQL_FILE into $DBNAME.$SCHEMA ..."

# Check file exists
if [[ ! -f "$SQL_FILE" ]]; then
  echo "❌ Error: File '$SQL_FILE' not found."
  exit 1
fi

psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DBNAME" <<EOF
SET search_path TO $SCHEMA;
\i $SQL_FILE
EOF

# Check exit code from psql
if [[ $? -ne 0 ]]; then
  echo "❌ Error: Failed to load $SQL_FILE into schema $SCHEMA."
  exit 1
fi

echo "✅ $SQL_FILE loaded successfully into schema $SCHEMA"