#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/init_$timestamp.log"
data_file="data_1k"

echo "[$(date +"%Y-%m-%d %T")] Init started" |& tee -a "$log_file"

{ 
  echo "[$(date +"%Y-%m-%d %T")] Reseting data" |& tee -a "$log_file"
  cypher-shell --format plain --log "logs/reset_verbose_$timestamp.log" < ./queries/db_reset.cypher | tee -a "$log_file"
  echo "[$(date +"%Y-%m-%d %T")] Finished reseting data" |& tee -a "$log_file"
} && \
{
  echo "[$(date +"%Y-%m-%d %T")] Inserting data" |& tee -a "$log_file"
  cypher-shell --format plain --log "logs/insert_verbose_$timestamp.log" < ./queries/"$data_file".cypher | tee -a "$log_file"
  echo "[$(date +"%Y-%m-%d %T")] Finished inserting data" |& tee -a "$log_file"
} && \
{ 
  echo "[$(date +"%Y-%m-%d %T")] Transforming data" |& tee -a "$log_file"
  cypher-shell --format plain --log "logs/transform_verbose_$timestamp.log" < ./queries/transform_data.cypher | tee -a "$log_file"
  echo "[$(date +"%Y-%m-%d %T")] Finished transforming data" |& tee -a "$log_file"
}

echo "[$(date +"%Y-%m-%d %T")] Init finished" |& tee -a "$log_file"
