#!/bin/bash

# Extract directory path and create it if it does not exist
LOG_DIR=$(dirname "../logs")
mkdir -p "$LOG_DIR"

# Define the base log filename
BASE_LOG_NAME="../logs/ExtractHistory"

# Get the current date and time in a specific format (e.g., YYYY-MM-DD_HH-MM-SS)
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")

# Construct the full log filename
LOG_FILENAME="${BASE_LOG_NAME}_${TIMESTAMP}.log"

echo "Log file will be: ${LOG_FILENAME}"

log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILENAME" 2>&1
}

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

#log_message "Valid date range from $from_date to $to_date"

set +x 
set -e  # Exit immediately if a command exits with a non-zero status
#cd ../
pwd
echo "$LOG_FILENAME"

#Collect reference tables
log_message "Collect reference data"

python  ../src/python/Staging_ReferenceTables.py >> "$LOG_FILENAME" 2>&1
if [ $? -ne 0 ]; then
    log_message "Staging_ReferenceTables.py failed. Exiting."
    log_message "Total runtime: ${SECONDS} Seconds"
    exit 1
fi
log_message "Reference Tables collected at ${SECONDS} Seconds"

#Collect Account related data
log_message "Collect Account related data"
#python  ../src/python/Staging_ExtractHistory.py $from_date $to_date >> "$LOG_FILENAME" 2>&1
if [ $? -ne 0 ]; then
    log_message "Staging_ExtractHistory.py failed. Exiting."
    log_message "Total runtime: ${SECONDS} Seconds"
    exit 1
fi
log_message "Account Information Tables collected at ${SECONDS} Seconds"

# Print the total runtime
log_message "Total runtime: ${SECONDS} Seconds"