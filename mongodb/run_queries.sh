#!/bin/bash

set -euo pipefail

record_volume=128000 # NOTE: Change this for every experiment with different data volume

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"

export RECORD_VOLUME=$record_volume

echo "[$(date +"%Y-%m-%d %T")] Query testing started" |& tee -a "$log_file"
mongosh --quiet "mongodb://localhost:27017/ecommerce" queries/query_testing.js |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Query testing finished" |& tee -a "$log_file"
