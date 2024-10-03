#!/bin/bash

# Set the URL for the WFS service
URL="https://geoserver.plandata.dk/geoserver/wfs"
SERVICE_PARAMS="servicename=wfs&request=getcapabilities&service=wfs&typename=pdk:theme_pdk_kommuneplan_oversigt_vedtaget_v"

# Specify the layer you want to update
SERVER_LAYER="pdk:theme_pdk_kommuneplan_oversigt_vedtaget_v"
LOCAL_LAYER="theme_pdk_kommuneplan_oversigt_vedtaget_v"

# Generate the timestamp for the day before yesterday at 17:00
# Read the last download timestamp from last_download.txt
LAST_DOWNLOAD_TIMESTAMP=$(cat last_download.txt)
echo "Using timestamp from last_download.txt: $LAST_DOWNLOAD_TIMESTAMP"

# Temporary table name for loading new data
TEMP_TABLE="plandata.tmp"

# Check if the temporary table exists and drop it before creating a new one
echo "Dropping temporary table if it exists..."
psql -d crawler -c "DROP TABLE IF EXISTS $TEMP_TABLE;"

# Fetch the entire layer without filtering by timestamp
echo "Fetching all records for layer: $SERVER_LAYER and loading into temporary table: $TEMP_TABLE"

# Execute the ogr2ogr command and skip the error if it fails
ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    --config OGR_WFS_URL "$URL" \
    --config OGR_WFS_BASEURL "$URL" \
    -where datoopdt > $LAST_DOWNLOAD_TIMESTAMP\
    -nln "$TEMP_TABLE" \
    -lco SCHEMA=plandata \
    -skipFailures \
    "$URL?$SERVICE_PARAMS" \
    "$SERVER_LAYER"

# Check if the ogr2ogr command was successful (but do not stop the script if it fails)
if [ $? -eq 0 ]; then
    echo "Successfully appended all records to the temporary table from $SERVER_LAYER"
else
    echo "Warning: Failed to append records to the temporary table from $SERVER_LAYER" >> error_log.txt  # Log the error
fi

# Reintroduce the SQL-based update to filter by timestamp
echo "Updating existing records in $LOCAL_LAYER"
psql -d crawler -c "UPDATE plandata.$LOCAL_LAYER 
    SET 
        ogc_fid = source.ogc_fid,
        gml_id = source.gml_id,
        oid_ = source.oid_,
        id = source.id,
        planid = source.planid,
        objektkode = source.objektkode,
        komnr = source.komnr,
        plannavn = source.plannavn,
        doklink = source.doklink,
        datoforsl = source.datoforsl,
        datovedt = source.datovedt,
        datoaflyst = source.datoaflyst,
        datoikraft = source.datoikraft,
        datoslut = source.datoslut,
        aktuel = source.aktuel,
        datooprt = source.datooprt,
        datoopdt = source.datoopdt,
        datostart = source.datostart,
        glkomnr = source.glkomnr,
        kommunenavn = source.kommunenavn,
        glkomnavn = source.glkomnavn,
        glkomnavn_besk = source.glkomnavn_besk,
        geometri = source.geometri
    FROM (SELECT * FROM $TEMP_TABLE WHERE datoopdt > '$LAST_DOWNLOAD_TIMESTAMP') AS source 
    WHERE plandata.$LOCAL_LAYER.ogc_fid = source.ogc_fid;"

# Check if the update command was successful
if [ $? -eq 0 ]; then
    echo "Successfully updated existing records in $LOCAL_LAYER"
else
    echo "Error updating existing records in $LOCAL_LAYER" >> error_log.txt  # Log the error
fi
