#!/bin/bash

# Determine the base directory of the script
BASE_DIR=$(dirname "$(realpath "$0")")

# Load the environment variables
export $(cat "$BASE_DIR/../../.env" | xargs)

# Create the table if it doesn't exist
CREATE_TABLE_SQL="
CREATE TABLE IF NOT EXISTS plandata_hash.theme_pdk_lokal_vedtaget_hashed_values (
    row_hash TEXT NOT NULL
);
"

# Run the table creation query
psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$CREATE_TABLE_SQL"

# Define the SQL query for inserting hashed values
INSERT_HASH_SQL="
INSERT INTO plandata_hash.theme_pdk_lokal_vedtaget_hashed_values (row_hash)
SELECT md5(
    COALESCE(CAST(ogc_fid AS TEXT), '') || '|' ||
    COALESCE(CAST(gml_id AS TEXT), '') || '|' ||
    COALESCE(CAST(oid_ AS TEXT), '') || '|' ||
    COALESCE(CAST(id AS TEXT), '') || '|' ||
    COALESCE(CAST(planid AS TEXT), '') || '|' ||
    COALESCE(CAST(komnr AS TEXT), '') || '|' ||
    COALESCE(CAST(objektkode AS TEXT), '') || '|' ||
    COALESCE(CAST(plantype AS TEXT), '') || '|' ||
    COALESCE(CAST(plannr AS TEXT), '') || '|' ||
    COALESCE(CAST(plannavn AS TEXT), '') || '|' ||
    COALESCE(CAST(anvgen AS TEXT), '') || '|' ||
    COALESCE(CAST(datoforsl AS TEXT), '') || '|' ||
    COALESCE(CAST(datovedt AS TEXT), '') || '|' ||
    COALESCE(CAST(datoaflyst AS TEXT), '') || '|' ||
    COALESCE(CAST(datoikraft AS TEXT), '') || '|' ||
    COALESCE(CAST(datostart AS TEXT), '') || '|' ||
    COALESCE(CAST(datoslut AS TEXT), '') || '|' ||
    COALESCE(CAST(datoattr AS TEXT), '') || '|' ||
    COALESCE(CAST(datogeom AS TEXT), '') || '|' ||
    COALESCE(CAST(doklink AS TEXT), '') || '|' ||
    COALESCE(CAST(distrikt AS TEXT), '') || '|' ||
    COALESCE(CAST(zone AS TEXT), '') || '|' ||
    COALESCE(CAST(bebygpct AS TEXT), '') || '|' ||
    COALESCE(CAST(bebygpctaf AS TEXT), '') || '|' ||
    COALESCE(CAST(bebygpctar AS TEXT), '') || '|' ||
    COALESCE(CAST(m3_m2 AS TEXT), '') || '|' ||
    COALESCE(CAST(maxetager AS TEXT), '') || '|' ||
    COALESCE(CAST(maxbygnhjd AS TEXT), '') || '|' ||
    COALESCE(CAST(minmiljo AS TEXT), '') || '|' ||
    COALESCE(CAST(maxmiljo AS TEXT), '') || '|' ||
    COALESCE(CAST(bevarbest AS TEXT), '') || '|' ||
    COALESCE(CAST(bebyggrad AS TEXT), '') || '|' ||
    COALESCE(CAST(mingrund AS TEXT), '') || '|' ||
    COALESCE(CAST(dataprod AS TEXT), '') || '|' ||
    COALESCE(CAST(digigrundl AS TEXT), '') || '|' ||
    COALESCE(CAST(digigrundd AS TEXT), '') || '|' ||
    COALESCE(CAST(datooprt AS TEXT), '') || '|' ||
    COALESCE(CAST(datoopdt AS TEXT), '') || '|' ||
    COALESCE(CAST(anvendelsegenerel AS TEXT), '') || '|' ||
    COALESCE(CAST(kommunenavn AS TEXT), '') || '|' ||
    COALESCE(CAST(zonestatus AS TEXT), '') || '|' ||
    COALESCE(CAST(planstatus AS TEXT), '') || '|' ||
    COALESCE(CAST(geometri AS TEXT), '')
) AS row_hash
FROM plandata.theme_pdk_lokalplan_vedtaget_v;
"

# Execute the insert query
psql -h "$DB_HOST" -d "$DB_NAME" -U "$DB_USER" -c "$INSERT_HASH_SQL"

echo "Hashed data written to the database."
