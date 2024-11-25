#!/bin/bash

# Determine the base directory of the script
BASE_DIR=$(dirname "$(realpath "$0")")

# Load the environment variables
export $(cat "$BASE_DIR/../../.env" | xargs)

# Create the table if it doesn't exist
CREATE_TABLE_SQL="
CREATE TABLE IF NOT EXISTS plandata_hash.theme_pdk_kommune_vedtaget_hashed_values (
    row_hash TEXT NOT NULL
);
"

# Run the table creation query
psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$CREATE_TABLE_SQL"

# Define the SQL query for inserting hashed values
INSERT_HASH_SQL="
INSERT INTO plandata_hash.theme_pdk_kommune_vedtaget_hashed_values (row_hash)
SELECT md5(
    COALESCE(CAST(ogc_fid AS TEXT), '') || '|' ||
    COALESCE(CAST(gml_id AS TEXT), '') || '|' ||
    COALESCE(CAST(oid_ AS TEXT), '') || '|' ||
    COALESCE(CAST(id AS TEXT), '') || '|' ||
    COALESCE(CAST(planid AS TEXT), '') || '|' ||
    COALESCE(CAST(objektkode AS TEXT), '') || '|' ||
    COALESCE(CAST(komnr AS TEXT), '') || '|' ||
    COALESCE(CAST(plannavn AS TEXT), '') || '|' ||
    COALESCE(CAST(doklink AS TEXT), '') || '|' ||
    COALESCE(CAST(datoforsl AS TEXT), '') || '|' ||
    COALESCE(CAST(datovedt AS TEXT), '') || '|' ||
    COALESCE(CAST(datoaflyst AS TEXT), '') || '|' ||
    COALESCE(CAST(datoikraft AS TEXT), '') || '|' ||
    COALESCE(CAST(datoslut AS TEXT), '') || '|' ||
    COALESCE(CAST(aktuel AS TEXT), '') || '|' ||
    COALESCE(CAST(datooprt AS TEXT), '') || '|' ||
    COALESCE(CAST(datoopdt AS TEXT), '') || '|' ||
    COALESCE(CAST(datostart AS TEXT), '') || '|' ||
    COALESCE(CAST(glkomnr AS TEXT), '') || '|' ||
    COALESCE(CAST(kommunenavn AS TEXT), '') || '|' ||
    COALESCE(CAST(glkomnavn AS TEXT), '') || '|' ||
    COALESCE(CAST(glkomnavn_besk AS TEXT), '') || '|' ||
    COALESCE(CAST(geometri AS TEXT), '')
) AS row_hash
FROM Plandata.theme_pdk_kommuneplan_oversigt_vedtaget_v;
"

# Execute the insert query
psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$INSERT_HASH_SQL"

echo "Hashed data written to the database."
