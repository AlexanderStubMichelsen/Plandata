#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")")

export $(cat $BASE_DIR/../../.env | xargs)

# This script runs all the update scripts for the relevant features

# Array of script filenames to run/ tables to update
SCRIPTS=("$BASE_DIR/../../update/bash_scripts/theme_pdk_kommuneplan_oversigt_forslag_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_kommuneplan_oversigt_vedtaget_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_lokalplan_forslag_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_lokalplan_vedtaget_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_zonekort_samlet_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_zonekort_v.sh")

# Clear error log at the start of the script
> $BASE_DIR/update_logs_and_error_etc/error_log.txt
# Creates the shema for this delta

psql -U "$PGUSER" -d $PGDATABASE -q -c "CREATE SCHEMA $SCHEMA"_"$(date +"%Y_%m_%d")"

# Get the current timestamp before running any scripts
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Loop through each script and execute it
for SCRIPT in "${SCRIPTS[@]}"; do
    echo "Running $SCRIPT..."

    # Run the script and capture its output and errors
    sh "$SCRIPT" >> "$BASE_DIR/update_logs_and_error_etc/script_output.log" 2>> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"
    
    # Check if the script executed successfully
    if [ $? -eq 0 ]; then
        echo "$SCRIPT executed successfully."
    else
        echo "Error: $SCRIPT failed to execute. $START_TIME" >> $BASE_DIR/update_logs_and_error_etc/error_log.txt
        # You can choose to exit on the first error, or comment this line to continue
        # exit 1  
    fi
done

# After all scripts have run, update the last download timestamp
echo "$START_TIME" > $BASE_DIR/update_logs_and_error_etc/last_download.txt
echo "Last download timestamp updated."
echo "Last download timestamp updated to $START_TIME." >> "$BASE_DIR/update_logs_and_error_etc/script_output.log"


echo "Setting up triggers"
psql -U "$PGUSER" -d $PGDATABASE -q -f $BASE_DIR/../../update/sql_scripts/create_plans_tables.sql 
psql -U "$PGUSER" -d $PGDATABASE -q -f $BASE_DIR/../../update/sql_scripts/triggers.sql 
psql -U "$PGUSER" -d $PGDATABASE -q -f $BASE_DIR/../../update/sql_scripts/remove_old_deltas.sql