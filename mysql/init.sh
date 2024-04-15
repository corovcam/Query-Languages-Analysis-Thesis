#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
data_file="data_256k"
log_file="logs/init_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Started creating schema" |& tee -a "$log_file"
mysql --user=root --password=root ecommerce < ./queries/schema.sql |& tee -a "$log_file" && \
mysql --user=root --password=root ecommerce < ./queries/procedures.sql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished creating schema" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing data" |& tee -a "$log_file"
mysql --max_allowed_packet=1G --user=root --password=root ecommerce < ./dumps/$data_file.sql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished importing data" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Setting up profiling" |& tee -a "$log_file"
mysql --user=root --password=root ecommerce < ./queries/setup_profiling.sql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished setting up profiling" |& tee -a "$log_file"
