#!/bin/bash

# Set the URL for the WFS service
URL="https://geoserver.plandata.dk/geoserver/wfs?servicename=wfs&request=getcapabilities&service=wfs"

# Schema that is to be updated
SCHEMA="plandata_test"

# Specify the layer you want to update
SERVER_LAYER="pdk:theme_pdk_zonekort_samlet_v"
LOCAL_LAYER="theme_pdk_zonekort_samlet_v"

# Read the last download timestamp from last_download.txt
if [[ -f "last_download.txt" ]]; then
    LAST_DOWNLOAD_TIMESTAMP=$(cat last_download.txt)
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
    -append \
    -skipfailures \
    &> ogr2ogr_log.txt

# Check if the ogr2ogr command was successful
if [ $? -eq 0 ]; then
    echo "Successfully appended all records to the local $LOCAL_LAYER table from $SERVER_LAYER"
else
    echo "Warning: Failed to append records to the local $LOCAL_LAYER table from $SERVER_LAYER" >> error_log.txt
    echo "Error details from ogr2ogr:" >> error_log.txt
    cat ogr2ogr_log.txt >> error_log.txt
    exit 1
fi
