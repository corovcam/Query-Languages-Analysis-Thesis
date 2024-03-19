#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

data_dir="data_256k/ecommerce"
log_file="logs/init_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Inserting collections" |& tee -a "$log_file"
if [ -n "$(ls "$data_dir"/*.bson 2>/dev/null)" ]
then
    # Contains BSON files from running `mongodump -d ecommerce -o "$data_dir"`
    mongorestore -d ecommerce --drop --verbose "$data_dir" |& tee -a "$log_file"
else
    for file in "$data_dir"/*.json; do
        fullFilename=$(basename "$file")
        filename=${fullFilename%.*}
        mongoimport --db ecommerce --collection "$filename" --drop --file "$file" --jsonArray |& tee -a "$log_file"
    done
fi
echo "[$(date +"%Y-%m-%d %T")] Finished inserting collections" |& tee -a "$log_file"
