# Get full path to script location
pwd
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $SCRIPT_DIR

pwd


echo "The job has run" > ./CronJobTest.log
