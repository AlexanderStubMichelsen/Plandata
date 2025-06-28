#!/usr/bin/env bash


URL="https://geoserver.plandata.dk/geoserver/wfs?servicename=wfs&request=getcapabilities&service=wfs"

SCHEMA=plandata_delta_test

TEST_DATE_START=2020-01-01
TEST_DATE_1=2020-04-01
TEST_DATE_2=2020-08-01
TEST_DATE_3=2020-12-01
TEST_DATE_4=2021-04-01
TEST_DATE_5=2021-08-01
TEST_DATE_END=2021-09-01

SERVER_LAYER="pdk:theme_pdk_kommuneplan_oversigt_vedtaget_v"
TEST_TABLE=delta_table
EXPECTED_TABLE=should_be_table

FAILED= false

LOG_FILE=../tests/logs/test_log.txt


psql -c "DROP SCHEMA IF EXISTS $SCHEMA CASCADE"
psql -c "CREATE SCHEMA $SCHEMA"


echo "------------------------"  >> $LOG_FILE
echo "Delta test:" $(date +"%Y-%m-%d %H:%M:%S") >> $LOG_FILE


#Detlas


ogr2ogr -f "PostgreSQL" PG:"dbname=postgres"\
    $URL\
    --config OGR_PG_ENABLE_METADATA=NO\
    -nln $TEST_TABLE "$SERVER_LAYER"\
    -where "datoopdt > '$TEST_DATE_START' AND datoopdt <= '$TEST_DATE_1'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=postgres" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$TEST_TABLE \
    -where "datoopdt > '$TEST_DATE_1' AND datoopdt <= '$TEST_DATE_2'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=postgres" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$TEST_TABLE \
    -where "datoopdt > '$TEST_DATE_2' AND datoopdt <= '$TEST_DATE_3'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=postgres" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$TEST_TABLE \
    -where "datoopdt > '$TEST_DATE_3' AND datoopdt <= '$TEST_DATE_4'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=postgres" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$TEST_TABLE \
    -where "datoopdt > '$TEST_DATE_4' AND datoopdt <= '$TEST_DATE_5'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=postgres" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$TEST_TABLE \
    -where "datoopdt > '$TEST_DATE_5' AND datoopdt <= '$TEST_DATE_END'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

#End tables

ogr2ogr -f "PostgreSQL" PG:"dbname=postgres"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln $EXPECTED_TABLE "$SERVER_LAYER"\
 -where "datoopdt > '$TEST_DATE_START' AND datoopdt <= '$TEST_DATE_END'" \
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures

EXPECTED_COUNT=`psql -AXqtc "SELECT COUNT(ogc_fid) FROM $SCHEMA.$EXPECTED_TABLE"`
ACTUAL_COUNT=`psql -AXqtc "SELECT  COUNT(ogc_fid) FROM $SCHEMA.$TEST_TABLE"`

if [ $ACTUAL_COUNT = $EXPECTED_COUNT ]; then
    echo "Same number of rows" >> $LOG_FILE
else 
    echo "Different number of rows" >> $LOG_FILE
    FAILED= true
fi

COUNT_OF_NEW_IDS_NOT_IN_DELTA=`psql -AXqtc "
    SELECT COUNT(id) FROM $SCHEMA.$EXPECTED_TABLE 
    WHERE id NOT IN (
	    SELECT id FROM $SCHEMA.$TEST_TABLE
    	)"`
NEW_IDS_NOT_IN_DELTA=`psql -AXqtc "
    SELECT id FROM $SCHEMA.$EXPECTED_TABLE 
    WHERE id NOT IN (
    	SELECT id FROM $SCHEMA.$TEST_TABLE
    	)"`

if [ "$COUNT_OF_NEW_IDS_NOT_IN_DELTA" = 0 ]; then
    echo "No ids missing from delta" >> $LOG_FILE
else
    echo "These ids are not in delta table: $NEW_IDS_NOT_IN_DELTA" >> $LOG_FILE
    FAILED= true
fi
psql -c "DROP SCHEMA IF EXISTS $SCHEMA CASCADE"
if $FAILED; then
    exit 1
fi