#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

data_dir="data_512k"
log_file="logs/dump_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Dumping BSON files" |& tee -a "$log_file"
mongodump -d ecommerce -o "$data_dir" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished dumping BSON files" |& tee -a "$log_file"
