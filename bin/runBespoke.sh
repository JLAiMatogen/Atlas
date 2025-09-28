#!/bin/bash

# Start the timer (SECONDS starts at 0 automatically)
SECONDS=0

# Read input arguments
from_date="$1"
to_date="$2"

# Detect if using BSD date (e.g. macOS) or GNU date (Linux)
is_bsd_date() {
    date --version >/dev/null 2>&1
    [ $? -ne 0 ]
}

# Function to validate date format
is_valid_date() {
    if is_bsd_date; then
        date -j -f "%Y-%m-%d" "$1" "+%Y-%m-%d" >/dev/null 2>&1
    else
        date -d "$1" "+%Y-%m-%d" >/dev/null 2>&1
    fi
}

# Function to convert to epoch
to_epoch() {
    if is_bsd_date; then
        date -j -f "%Y-%m-%d" "$1" "+%s"
    else
        date -d "$1" "+%s"
    fi
}

# Validate dates
if ! is_valid_date "$from_date"; then
    echo "Error: Invalid from_date format: $from_date"
    exit 1
fi

if ! is_valid_date "$to_date"; then
    echo "Error: Invalid to_date format: $to_date"
    exit 1
fi

from_epoch=$(to_epoch "$from_date")
to_epoch=$(to_epoch "$to_date")

if [ "$to_epoch" -le "$from_epoch" ]; then
    echo "Error: to_date ($to_date) must be after from_date ($from_date)"
    exit 1
fi

echo "Valid date range from $from_date to $to_date"

set +x 
set -e  # Exit immediately if a command exits with a non-zero status
cd ../
pwd

echo "Collect reference data"
#python  Bespoke_ReferenceTables.py
if [ $? -ne 0 ]; then
    echo "Bespoke_ReferenceTables.py failed. Exiting."
    echo "Total runtime: ${SECONDS} Seconds"
    exit 1
fi
echo "Reference Tables collected at ${SECONDS} Seconds"

echo "Collect Application related data"
python  Bespoke_ExtractHistory.py $from_date $to_date
if [ $? -ne 0 ]; then
    echo "Bespoke_ExtractHistory.py failed. Exiting."
    echo "Total runtime: ${SECONDS} Seconds"
    exit 1
fi
echo "Application Information Tables collected at ${SECONDS} Seconds"

# Print the total runtime
echo "Total runtime: ${SECONDS} Seconds"

cd -