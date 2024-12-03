#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")")
export $(cat "$BASE_DIR/../../.env" | xargs)

# OBS this script compare all the newly updated and hashed tables vs the old hashed tables.

# Array of script filenames to run for comparing the hashed values for each table
SCRIPTS=("$BASE_DIR/../../hashing_and_comparing/comparing/compare_hash_kommune_forslag.sh"
         "$BASE_DIR/../../hashing_and_comparing/comparing/compare_hash_kommune_vedtaget.sh"
         "$BASE_DIR/../../hashing_and_comparing/comparing/compare_hash_lokal_forslag.sh"
         "$BASE_DIR/../../hashing_and_comparing/comparing/compare_hash_lokal_vedtaget.sh"
         "$BASE_DIR/../../hashing_and_comparing/comparing/compare_hash_zonekort_samlet.sh"
         "$BASE_DIR/../../hashing_and_comparing/comparing/compare_hash_zonekort.sh")

# Clear error log at the start of the script
> "$BASE_DIR/comparing_logs_and_error/error_log_comparing.txt"

# Get the current timestamp before running any scripts
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Loop through each script and execute it
for SCRIPT in "${SCRIPTS[@]}"; do
    echo "Running $SCRIPT..."

    # Run the script and capture its output and errors
    sh "$SCRIPT" >> "$BASE_DIR/comparing_logs_and_error/comparing_script_output.log" 2>> "$BASE_DIR/comparing_logs_and_error/error_log_comparing.txt"
    
    # Check if the script executed successfully
    if [ $? -eq 0 ]; then
        echo "$SCRIPT executed successfully."
    else
        echo "Error: $SCRIPT failed to execute at $START_TIME" >> "$BASE_DIR/comparing_logs_and_error/error_log_comparing.txt"
        # Optionally exit on the first error, or comment this line to continue
        # exit 1  
    fi
done

echo "Comparing was run at $START_TIME." >> "$BASE_DIR/comparing_logs_and_error/comparing_script_output.log"
