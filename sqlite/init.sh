#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
data_file="data_128k"
log_file="logs/init_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Started creating schema" 2>&1 | tee -a "$log_file"
sqlite3 data/ecommerce.db < ./queries/schema.sql 2>&1 | tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished creating schema" 2>&1 | tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing data" 2>&1 | tee -a "$log_file"
sqlite3 data/ecommerce.db < ./dumps/"$data_file".sql 2>&1 | tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished importing data" 2>&1 | tee -a "$log_file"
