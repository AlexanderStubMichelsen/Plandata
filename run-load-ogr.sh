#!/bin/bash
# Wrapper script to run load-ogr.sh with proper encoding settings

# Set environment variables for UTF-8 handling
export PGCLIENTENCODING=UTF8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Ensure we're using OSGeo4W GDAL
export PATH="/c/OSGeo4W/bin:$PATH"

echo "Setting up environment for UTF-8 encoding..."
echo "PGCLIENTENCODING=$PGCLIENTENCODING"
echo "LC_ALL=$LC_ALL"
echo "LANG=$LANG"
echo ""

# Run the original script
echo "Running load-ogr.sh with proper encoding..."
./load-ogr.sh
