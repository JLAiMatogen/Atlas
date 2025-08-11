#!/bin/bash


# Get full path to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Activate the virtual environment (use full path)
source "${HOME}/venv_matogen/bin/activate"

set +x 
set -e  # Exit immediately if a command exits with a non-zero status

# Extract directory path and create it if it does not exist
LOG_DIR=$(dirname "../logs")
mkdir -p "$LOG_DIR"

# Define the base log filename
BASE_LOG_NAME="../logs/ExtractDelta"

# Get the current date and time in a specific format (e.g., YYYY-MM-DD_HH-MM-SS)
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")

# Construct the full log filename
LOG_FILENAME="${BASE_LOG_NAME}_${TIMESTAMP}.log"

#Define how log messages are written
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILENAME" 2>&1
}

# Start the timer (SECONDS starts at 0 automatically)
SECONDS=0

echo "Log file will be: ${LOG_FILENAME}"

#Collect reference data
log_message "Collect reference data"
python  ../src/python/Staging_ReferenceTables.py >> "$LOG_FILENAME" 2>&1
if [ $? -ne 0 ]; then
    echo "Staging_ReferenceTables.py failed. Exiting."
    exit 1
fi
log_message "Reference Tables collected at ${SECONDS} Seconds"


#Collect Account related data
log_message "Collect Account related data"
python  ../src/python/Staging_ExtractDelta.py $from_date $to_date >> "$LOG_FILENAME" 2>&1
if [ $? -ne 0 ]; then
    echo "Staging_ExtractDelta.py failed. Exiting."
    exit 1
fi

log_message "Account Information Tables collected at ${SECONDS} Seconds"
# Print the total runtime
log_message "Total runtime: ${SECONDS} Seconds"
