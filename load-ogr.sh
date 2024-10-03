#!/bin/bash
URL="https://geoserver.plandata.dk/geoserver/wfs?servicename=wfs&request=getcapabilities&service=wfs"

ogr2ogr -f "PostgreSQL" PG:"dbname=crawler" -lco SCHEMA=plandata -skipfailures $URL
