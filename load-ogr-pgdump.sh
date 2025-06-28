#!/bin/bash
URL="https://geoserver.plandata.dk/geoserver/wfs?servicename=wfs&request=getcapabilities&service=wfs"

SCHEMA=plandata

# Create SQL files using PGDUMP format instead of direct PostgreSQL connection
echo "Creating SQL dump files for import..."

ogr2ogr -f "PGDUMP" "theme_pdk_kommuneplan_oversigt_forslag_v.sql"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln theme_pdk_kommuneplan_oversigt_forslag_v "pdk:theme_pdk_kommuneplan_oversigt_forslag_v"\
 -lco SCHEMA=$SCHEMA\
 -lco DROP_TABLE=IF_EXISTS\
 -skipfailures

ogr2ogr -f "PGDUMP" "theme_pdk_kommuneplan_oversigt_vedtaget_v.sql"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln theme_pdk_kommuneplan_oversigt_vedtaget_v "pdk:theme_pdk_kommuneplan_oversigt_vedtaget_v"\
 -lco SCHEMA=$SCHEMA\
 -lco DROP_TABLE=IF_EXISTS\
 -skipfailures

ogr2ogr -f "PGDUMP" "theme_pdk_lokalplan_forslag_v.sql"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln theme_pdk_lokalplan_forslag_v "pdk:theme_pdk_lokalplan_forslag_v"\
 -lco SCHEMA=$SCHEMA\
 -lco DROP_TABLE=IF_EXISTS\
 -skipfailures

ogr2ogr -f "PGDUMP" "theme_pdk_lokalplan_vedtaget_v.sql"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln theme_pdk_lokalplan_vedtaget_v "pdk:theme_pdk_lokalplan_vedtaget_v"\
 -lco SCHEMA=$SCHEMA\
 -lco DROP_TABLE=IF_EXISTS\
 -skipfailures

ogr2ogr -f "PGDUMP" "theme_pdk_zonekort_samlet_v.sql"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln theme_pdk_zonekort_samlet_v "pdk:theme_pdk_zonekort_samlet_v"\
 -lco SCHEMA=$SCHEMA\
 -lco DROP_TABLE=IF_EXISTS\
 -skipfailures

ogr2ogr -f "PGDUMP" "theme_pdk_zonekort_v.sql"\
 $URL\
 --config OGR_PG_ENABLE_METADATA=NO\
 -nln theme_pdk_zonekort_v "pdk:theme_pdk_zonekort_v"\
 -lco SCHEMA=$SCHEMA\
 -lco DROP_TABLE=IF_EXISTS\
 -skipfailures

echo "SQL files created. Import them to PostgreSQL using:"
echo "psql -U postgres -d postgres -f theme_pdk_kommuneplan_oversigt_forslag_v.sql"
echo "psql -U postgres -d postgres -f theme_pdk_kommuneplan_oversigt_vedtaget_v.sql"
echo "psql -U postgres -d postgres -f theme_pdk_lokalplan_forslag_v.sql"
echo "psql -U postgres -d postgres -f theme_pdk_lokalplan_vedtaget_v.sql"
echo "psql -U postgres -d postgres -f theme_pdk_zonekort_samlet_v.sql"
echo "psql -U postgres -d postgres -f theme_pdk_zonekort_v.sql"
