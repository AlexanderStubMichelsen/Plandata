#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")")

# Load environment variables
export $(cat "$BASE_DIR/../../.env" | xargs)

# Array of script filenames to run/ tables to update
SCRIPTS=("$BASE_DIR/../../update/bash_scripts/theme_pdk_kommuneplan_oversigt_forslag_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_kommuneplan_oversigt_vedtaget_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_lokalplan_forslag_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_lokalplan_vedtaget_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_zonekort_samlet_v_update.sh"
         "$BASE_DIR/../../update/bash_scripts/theme_pdk_zonekort_v.sh")

HASFAILED=FALSE

# Clear the error log at the start of the script
> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"

# Create the schema for this delta (if it doesn't exist)
SCHEMA_NAME="${SCHEMA}_$(date +"%Y_%m_%d")"
psql -U "$PGUSER" -d "$PGDATABASE" -q -c "DO \$\$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.schemata WHERE schema_name = '$SCHEMA_NAME'
    ) THEN
        EXECUTE 'CREATE SCHEMA $SCHEMA_NAME';
    END IF;
END \$\$;" 2>> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"

# Check for schema creation errors
if [ $? -ne 0 ]; then
    echo "Error: Failed to create schema $SCHEMA_NAME." >> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"
    HASFAILED=TRUE
fi

# Get the current timestamp
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
        echo "Error: $SCRIPT failed to execute at $START_TIME" >> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"
        # Uncomment the next line to stop on first error
        HASFAILED=TRUE
    fi
done

# Update the last download timestamp
echo "$START_TIME" > "$BASE_DIR/update_logs_and_error_etc/last_download.txt"
echo "Last download timestamp updated to $START_TIME." >> "$BASE_DIR/update_logs_and_error_etc/script_output.log"

# Execute SQL scripts for triggers and cleanup
echo "Setting up triggers..."
psql -U "$PGUSER" -d "$PGDATABASE" -q -f "$BASE_DIR/../../update/sql_scripts/create_plans_tables.sql" 2>> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"
psql -U "$PGUSER" -d "$PGDATABASE" -q -f "$BASE_DIR/../../update/sql_scripts/triggers.sql" 2>> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"
psql -U "$PGUSER" -d "$PGDATABASE" -q -f "$BASE_DIR/../../update/sql_scripts/remove_old_deltas.sql" 2>> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"

# Check for SQL execution errors
if [ $? -ne 0 ]; then
    echo "Error: One or more SQL scripts failed to execute." >> "$BASE_DIR/update_logs_and_error_etc/error_log.txt"
    HASFAILED=true
fi

if $HASFAILED; then 
    exit 1
fi
