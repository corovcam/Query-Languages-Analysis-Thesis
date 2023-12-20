#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

data_dir="data_old"

for file in "$data_dir"/*.json; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    mongoimport --db ecommerce --collection "$filename" --drop --file "$file" --jsonArray |& tee -a logs/import_"$timestamp".log
done