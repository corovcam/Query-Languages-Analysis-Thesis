#!/bin/bash

# Run this script only if you already have the generated data in the data_dir directory
# If you don't have the data, use MongoDB Relational Migrator to generate it first

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%s")

data_dir="dumps/data_1k/ecommerce"
log_file="logs/init_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Inserting collections" |& tee -a "$log_file"
if [ -n "$(ls "$data_dir"/*.bson 2>/dev/null)" ] # Check if directory contains BSON files
then
    # Contains BSON files from running `mongodump -d ecommerce -o "$data_dir"`
    mongorestore -d ecommerce --drop --verbose "$data_dir" |& tee -a "$log_file"
else # Otherwise it should contain JSON Array files to import
    for file in "$data_dir"/*.json; do
        fullFilename=$(basename "$file")
        filename=${fullFilename%.*}
        mongoimport --db ecommerce --collection "$filename" --drop --file "$file" --jsonArray |& tee -a "$log_file"
    done
fi
echo "[$(date +"%Y-%m-%d %T")] Finished inserting collections" |& tee -a "$log_file"
