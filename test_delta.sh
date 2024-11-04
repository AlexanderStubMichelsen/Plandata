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
LOCAL_LAYER_0=start_table
LOCAL_LAYER_1=deta_table
LOCAL_LAYER_2=shuld_be_table

PGHOST=localhost
PGPASSWORD=gYKchc21hx5RNUvX
PGDATABASE=crawler
PGUSER=crawler

psql -c "DROP SCHEMA IF EXISTS $SCHEMA CASCADE"
psql -c "CREATE SCHEMA $SCHEMA"

# start table
ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln $LOCAL_LAYER_0 "$SERVER_LAYER"\
 -where "datoopdt <= '$TEST_DATE_START'" \
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures

#Detlas

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
    $URL\
    --config OGR_PG_ENABLE_METADATA=NO\
    -nln $LOCAL_LAYER_1 "$SERVER_LAYER"\
    -where "datoopdt <= '$TEST_DATE_START'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$LOCAL_LAYER_1 \
    -where "datoopdt > '$TEST_DATE_1' AND datoopdt <= '$TEST_DATE_2'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$LOCAL_LAYER_1 \
    -where "datoopdt > '$TEST_DATE_2' AND datoopdt <= '$TEST_DATE_3'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$LOCAL_LAYER_1 \
    -where "datoopdt > '$TEST_DATE_3' AND datoopdt <= '$TEST_DATE_4'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$LOCAL_LAYER_1 \
    -where "datoopdt > '$TEST_DATE_4' AND datoopdt <= '$TEST_DATE_5'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" \
    "$URL" "$SERVER_LAYER" \
    -nln $SCHEMA.$LOCAL_LAYER_1 \
    -where "datoopdt > '$TEST_DATE_5' AND datoopdt <= '$TEST_DATE_END'" \
    -lco SCHEMA=$SCHEMA \
    -update \
    -append \
    -skipfailures \

#End tables

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln $LOCAL_LAYER_2 "$SERVER_LAYER"\
 -where "datoopdt <= '$TEST_DATE_END'" \
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures

psql -c "SELECT ogc_fid FROM $SCHEMA.$LOCAL_LAYER_0" -a
psql -c "SELECT ogc_fid FROM $SCHEMA.$LOCAL_LAYER_1" -a
psql -c "SELECT ogc_fid FROM $SCHEMA.$LOCAL_LAYER_2" -a
