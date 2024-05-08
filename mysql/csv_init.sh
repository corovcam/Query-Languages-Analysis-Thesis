#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
data_dir="dumps/data_2M48k" # NOTE: Change this to the dump directory you want to import
log_file="logs/init_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Started creating schema" |& tee -a "$log_file"
mysql --user=root --password=root ecommerce < ./queries/schema.sql |& tee -a "$log_file" && \
mysql --user=root --password=root ecommerce < ./queries/procedures.sql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished creating schema" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing data" |& tee -a "$log_file"
for file in "$data_dir"/*.csv; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    echo "[$(date +"%Y-%m-%d %T")] Importing $file" |& tee -a "$log_file"
    mysql --user=root --password=root -e "SET foreign_key_checks = 0;" -e "LOAD DATA INFILE '/mysql/$data_dir/$fullFilename' INTO TABLE \`$filename\` FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\'';" ecommerce |& tee -a "$log_file"
    echo "[$(date +"%Y-%m-%d %T")] Finished importing $file" |& tee -a "$log_file"
done
echo "[$(date +"%Y-%m-%d %T")] Finished importing data" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Setting up profiling" |& tee -a "$log_file"
mysql --user=root --password=root ecommerce < ./queries/setup_profiling.sql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished setting up profiling" |& tee -a "$log_file"
