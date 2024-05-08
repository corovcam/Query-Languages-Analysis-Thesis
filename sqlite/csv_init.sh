#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
data_dir="dumps/data_1M24k" # NOTE: Change this to the dump directory you want to import
log_file="logs/init_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Started creating schema" 2>&1 | tee -a "$log_file"
sqlite3 data/ecommerce.db < ./queries/schema.sql 2>&1 | tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished creating schema" 2>&1 | tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing data" 2>&1 | tee -a "$log_file"
for file in "$data_dir"/*.csv; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    echo "[$(date +"%Y-%m-%d %T")] Importing $file" 2>&1 | tee -a "$log_file"
    sqlite3 data/ecommerce.db "PRAGMA foreign_keys = OFF; .import --csv '/sqlite/$data_dir/$fullFilename' $filename; PRAGMA foreign_keys = ON;" 2>&1 | tee -a "$log_file"
    echo "[$(date +"%Y-%m-%d %T")] Finished importing $file" 2>&1 | tee -a "$log_file"
done
echo "[$(date +"%Y-%m-%d %T")] Finished importing data" 2>&1 | tee -a "$log_file"
