#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

data_dir="data_1k"

if [ -n "$(ls "$data_dir"/*.bson 2>/dev/null)" ]
then
    # Contains BSON files from running `mongodump -d ecommerce -o "$data_dir"`
    mongorestore -d ecommerce "$data_dir" |& tee -a logs/import_"$timestamp".log
else
    for file in "$data_dir"/*.json; do
        fullFilename=$(basename "$file")
        filename=${fullFilename%.*}
        mongoimport --db ecommerce --collection "$filename" --drop --file "$file" --jsonArray |& tee -a logs/import_"$timestamp".log
    done
fi
