#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%s")
data_file="dumps/data_256k.cql" # Change this to the desired data file

log_file="logs/init_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Creating schema" |& tee -a "$log_file"
cqlsh -f ./queries/schema.cql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished creating schema" |& tee -a "$log_file"

log_file="logs/data_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Inserting data" |& tee -a "$log_file"
cqlsh -f ./queries/"$data_file" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished inserting data" |& tee -a "$log_file"
