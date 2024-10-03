#!/bin/bash

# Array of script filenames to run
SCRIPTS=("theme_pdk_kommuneplan_oversigt_forslag_v_update.sh"
 "theme_pdk_kommuneplan_oversigt_vedtaget_v_update.sh"
  "theme_pdk_lokalplan_forslag_v_update.sh"
   "theme_pdk_lokalplan_vedtaget_v_update.sh"
    "theme_pdk_zonekort_samlet_v_update.sh"
    "theme_pdk_zonekort_v.sh")

# Loop through each script and execute it
for SCRIPT in "${SCRIPTS[@]}"; do
    echo "Running $SCRIPT..."
    sh "$SCRIPT"
    
    # Check if the script executed successfully
    if [ $? -eq 0 ]; then
        echo "$SCRIPT executed successfully."
    else
        echo "Error: $SCRIPT failed to execute." >> error_log.txt
        # You may choose to exit on error or continue
        exit 1  # Uncomment if you want to stop on the first error
    fi
done
psql DROP TABLE IF EXISTS plandata.tmp
# Update the last download timestamp after all scripts have run
date +"%Y-%m-%d %H:%M:%S" > last_download.txt
echo "Last download timestamp updated."
