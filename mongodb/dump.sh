#!/bin/bash

# Used to dump the current state of the MongoDB database to BSON files.

timestamp=$(date +"%Y-%m-%d_%s")

log_file="logs/dump_$timestamp.log"
data_dir="dumps/data_$timestamp"

mkdir -p "$data_dir"

echo "[$(date +"%Y-%m-%d %T")] Dumping BSON files" |& tee -a "$log_file"
mongodump -d ecommerce -o "$data_dir" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished dumping BSON files" |& tee -a "$log_file"

chmod -R 777 "$data_dir"
