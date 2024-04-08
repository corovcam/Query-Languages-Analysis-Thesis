#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

data_dir="dumps/data_512k"
log_file="logs/dump_$timestamp.log"

mkdir -p "$data_dir"

echo "[$(date +"%Y-%m-%d %T")] Dumping BSON files" |& tee -a "$log_file"
mongodump -d ecommerce -o "$data_dir" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished dumping BSON files" |& tee -a "$log_file"

chmod -R 777 "$data_dir"
