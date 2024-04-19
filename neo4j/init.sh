#!/bin/bash

# Use this script only if you already have the generated data present in the form of the CYPHER dump file generated using  dump_to_cypher.sh script.

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/init_$timestamp.log"
data_file="dumps/data_1k.cypher" # NOTE: Change this to the desired CYPHER data file (if any)

echo "[$(date +"%Y-%m-%d %T")] Init started" |& tee -a "$log_file"

{ 
  echo "[$(date +"%Y-%m-%d %T")] Reseting data" |& tee -a "$log_file"
  cypher-shell --format plain --log "logs/reset_verbose_$timestamp.log" < ./queries/db_reset.cypher | tee -a "$log_file"
  echo "[$(date +"%Y-%m-%d %T")] Finished reseting data" |& tee -a "$log_file"
} && \
{
  echo "[$(date +"%Y-%m-%d %T")] Inserting data" |& tee -a "$log_file"
  cypher-shell --format plain --log "logs/insert_verbose_$timestamp.log" < "$data_file" | tee -a "$log_file"
  echo "[$(date +"%Y-%m-%d %T")] Finished inserting data" |& tee -a "$log_file"
} && \
{ 
  echo "[$(date +"%Y-%m-%d %T")] Transforming data" |& tee -a "$log_file"
  cypher-shell --format plain --log "logs/transform_verbose_$timestamp.log" < ./queries/transform_data.cypher | tee -a "$log_file"
  echo "[$(date +"%Y-%m-%d %T")] Finished transforming data" |& tee -a "$log_file"
}

echo "[$(date +"%Y-%m-%d %T")] Init finished" |& tee -a "$log_file"
