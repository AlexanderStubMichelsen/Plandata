#!/bin/bash

export $(cat ../../.env | xargs)

# Determine the base directory of the script
BASE_DIR=$(dirname "$(realpath "$0")")

# Ensure the target schema exists
CREATE_SCHEMA_SQL="
CREATE SCHEMA IF NOT EXISTS plandata_hash_old;
"
psql -U "$PGUSER" -d "$PGDATABASE" -q -c "$CREATE_SCHEMA_SQL"

# Define the SQL to drop all tables in plandata_hash_old schema
DROP_FROM_HASH_OLD_SQL="
DO \$\$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT information_schema.tables.table_name
        FROM information_schema.tables
        WHERE table_schema = 'plandata_hash_old'
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS plandata_hash_old.' || tbl_name || ' CASCADE;';
    END LOOP;
END \$\$;
"

# Run the SQL using psql
psql -U "$PGUSER" -d "$PGDATABASE" -q -c "$DROP_FROM_HASH_OLD_SQL"

# Check execution status
if [ $? -eq 0 ]; then
    echo "All tables in the plandata_hash_old schema have been dropped successfully."
else
    echo "An error occurred while dropping tables from the plandata_hash_old schema."
fi

# Check if there are tables in the plandata_hash schema that need renaming
CHECK_TABLES_SQL="
SELECT COUNT(*)
FROM information_schema.tables
WHERE table_schema = 'plandata_hash' AND table_name NOT LIKE '%_old';
"

TABLE_COUNT=$(psql -U "$PGUSER" -d "$PGDATABASE" -t -c "$CHECK_TABLES_SQL" | xargs)

if [ "$TABLE_COUNT" -gt 0 ]; then
    echo "Found $TABLE_COUNT table(s) in plandata_hash schema. Renaming and moving to plandata_hash_old..."

    # Rename tables by appending `_old`
    RENAME_TABLES_SQL="
    DO \$\$
    DECLARE
        table_name TEXT;
    BEGIN
        FOR table_name IN
            SELECT t.table_name
            FROM information_schema.tables t
            WHERE t.table_schema = 'plandata_hash' AND t.table_name NOT LIKE '%_old'
        LOOP
            EXECUTE FORMAT('ALTER TABLE plandata_hash.%I RENAME TO %I_old', table_name, table_name);
        END LOOP;
    END \$\$;
    "

    echo "Renaming tables..."
    psql -U "$PGUSER" -d "$PGDATABASE" -q -c "$RENAME_TABLES_SQL"
    echo "Table renaming completed."

    # Move renamed tables to the plandata_hash_old schema
    MOVE_TABLES_SQL="
    DO \$\$
    DECLARE
        table_name TEXT;
    BEGIN
        FOR table_name IN
            SELECT t.table_name
            FROM information_schema.tables t
            WHERE t.table_schema = 'plandata_hash' AND t.table_name LIKE '%_old'
        LOOP
            EXECUTE FORMAT('ALTER TABLE plandata_hash.%I SET SCHEMA plandata_hash_old', table_name);
        END LOOP;
    END \$\$;
    "

    echo "Moving renamed tables to plandata_hash_old..."
    psql -U "$PGUSER" -d "$PGDATABASE" -q -c "$MOVE_TABLES_SQL"
    echo "Table moving completed."
else
    echo "No tables found in plandata_hash schema to rename or move."
fi

# Get the current timestamp before running any scripts
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Array of script filenames to run
SCRIPTS=("$BASE_DIR/../../hashing_and_comparing/hashing/hash_kommune_forslag.sh"
         "$BASE_DIR/../../hashing_and_comparing/hashing/hash_kommune_vedtaget.sh"
         "$BASE_DIR/../../hashing_and_comparing/hashing/hash_lokal_forslag.sh"
         "$BASE_DIR/../../hashing_and_comparing/hashing/hash_lokal_vedtaget.sh"
         "$BASE_DIR/../../hashing_and_comparing/hashing/hash_zonekort_samlet.sh"
         "$BASE_DIR/../../hashing_and_comparing/hashing/hash_zonekort_v.sh")

# Loop through each script and execute it
for SCRIPT in "${SCRIPTS[@]}"; do
    echo "Running $SCRIPT..."

    # Run the script and capture its output and errors
    sh "$SCRIPT" >> "$BASE_DIR/hash_logs_and_error_etc/hash_script_output.log" 2>> "$BASE_DIR/hash_logs_and_error_etc/error_log_hash.txt"
    
    # Check if the script executed successfully
    if [ $? -eq 0 ]; then
        echo "$SCRIPT executed successfully."
    else
        echo "Error: $SCRIPT failed to execute at $START_TIME." >> $BASE_DIR/hash_logs_and_error_etc/error_log_hash.txt
        # Exit on error, or comment this line to continue
        # exit 1  
    fi
done

# After all scripts have run, update the last download timestamp
echo "$START_TIME" > $BASE_DIR/hash_logs_and_error_etc/last_download_hash.txt
echo "Last download hash timestamp updated."
echo "Last download hash timestamp updated to $START_TIME." >> "$BASE_DIR/hash_logs_and_error_etc/hash_script_output.log"
