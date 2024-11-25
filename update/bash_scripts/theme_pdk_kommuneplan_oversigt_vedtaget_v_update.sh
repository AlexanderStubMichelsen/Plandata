#!/bin/bash
export $(cat ../../.env | xargs)

# Set the URL for the WFS service
URL="https://geoserver.plandata.dk/geoserver/wfs?servicename=wfs&request=getcapabilities&service=wfs"

DELTA_SCHEMA="$SCHEMA"_"$(date +"%Y_%m_%d")"

# Specify the layer you want to update
SERVER_LAYER="pdk:theme_pdk_kommuneplan_oversigt_vedtaget_v"
LOCAL_LAYER="theme_pdk_kommuneplan_oversigt_vedtaget_v"

# Read the last download timestamp from last_download.txt
if [[ -f "../../master_scripts/update/update_logs_and_error_etc/last_download.txt" ]]; then
    LAST_DOWNLOAD_TIMESTAMP=$(cat ../../master_scripts/update/update_logs_and_error_etc/last_download.txt)
    echo "Using timestamp from last_download.txt: $LAST_DOWNLOAD_TIMESTAMP"
else
    echo "Error: last_download.txt not found." >> error_log.txt
    exit 1
fi

# Set to avoid ogr2ogr creating event triggers
export PG_USE_COPY=YES

# Execute the ogr2ogr command with append option
ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    "$URL" "$SERVER_LAYER" \
    -nln "$SCHEMA.$LOCAL_LAYER" \
    -where "datoopdt > '$LAST_DOWNLOAD_TIMESTAMP'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \
    &> ../../master_scripts/update/update_logs_and_error_etc/ogr2ogr_log.txt

# Also save the delta in a seperate schema
ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    "$URL" "$SERVER_LAYER" \
    -nln "$DELTA_SCHEMA.$LOCAL_LAYER" \
    -where "datoopdt > '$LAST_DOWNLOAD_TIMESTAMP'" \
    -lco SCHEMA=$DELTA_SCHEMA \
    -update \
    -append \
    -skipfailures \
    &> ../../master_scripts/update/update_logs_and_error_etc/ogr2ogr_log.txt

# Check if the ogr2ogr command was successful
if [ $? -eq 0 ]; then
    echo "Successfully appended all records to the local $LOCAL_LAYER table from $SERVER_LAYER"
else
    echo "Warning: Failed to append records to the local $LOCAL_LAYER table from $SERVER_LAYER" >> ../../master_scripts/update/update_logs_and_error_etc/error_log.txt
    echo "Error details from ogr2ogr:" >> ../../master_scripts/update/update_logs_and_error_etc/error_log.txt
    cat ../../master_scripts/update/update_logs_and_error_etc/ogr2ogr_log.txt >> ../../master_scripts/update/update_logs_and_error_etc/error_log.txt
    exit 1
fi
