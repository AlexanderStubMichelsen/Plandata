#!/bin/bash

# Determine the base directory of the script
BASE_DIR=$(dirname "$(realpath "$0")")

# Load the environment variables
export $(cat "$BASE_DIR/../../.env" | xargs)

# Define the SQL query
COMPARE_SQL="
SELECT
    'Removed' AS status, old.row_hash
FROM plandata_hash_old.theme_pdk_zonekort_hashed_values_old old
LEFT JOIN plandata_hash.theme_pdk_zonekort_hashed_values new
ON old.row_hash = new.row_hash
WHERE new.row_hash IS NULL

UNION ALL

SELECT
    'Added' AS status, new.row_hash
FROM plandata_hash.theme_pdk_zonekort_hashed_values new
LEFT JOIN plandata_hash_old.theme_pdk_zonekort_hashed_values_old old
ON new.row_hash = old.row_hash
WHERE old.row_hash IS NULL;
"

# Run the query
psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$COMPARE_SQL" > "$BASE_DIR/../../master_scripts/comparing/comparing_results/comparison_results_zonekort.csv"

echo "Comparison results saved to comparison_results.csv"
