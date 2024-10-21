#!/bin/bash
URL="https://geoserver.plandata.dk/geoserver/wfs?servicename=wfs&request=getcapabilities&service=wfs"

SCHEMA=plandata_test

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 -nln theme_pdk_kommuneplan_oversigt_forslag_v "pdk:theme_pdk_kommuneplan_oversigt_forslag_v"\
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 -nln theme_pdk_kommuneplan_oversigt_vedtaget_v "pdk:theme_pdk_kommuneplan_oversigt_vedtaget_v"\
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 -nln theme_pdk_lokalplan_forslag_v "pdk:theme_pdk_lokalplan_forslag_v"\
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 -nln theme_pdk_lokalplan_vedtaget_v "pdk:theme_pdk_lokalplan_vedtaget_v"\
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 -nln theme_pdk_zonekort_samlet_v "pdk:theme_pdk_zonekort_samlet_v"\
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures
ogr2ogr -f "PostgreSQL" PG:"dbname=crawler"\
 $URL\
 -nln theme_pdk_zonekort_v "pdk:theme_pdk_zonekort_v"\
 -lco SCHEMA=$SCHEMA\
 -lco OVERWRITE=YES\
 -skipfailures


