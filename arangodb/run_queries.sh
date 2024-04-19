#!/bin/sh

set -eu

record_volume=128000 # NOTE: Change this for every experiment with different data volume

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"

export RECORD_VOLUME=$record_volume

echo "[$(date +"%Y-%m-%d %T")] Starting query testing" 2>&1 | tee -a "$log_file"
arangosh \
  --server.authentication false \
  --log.level trace \
  --server.request-timeout 300 \
  --javascript.environment-variables-allowlist RECORD_VOLUME \
  --javascript.v8-max-heap 8192 < queries/query_testing.js 2>&1 | tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished query testing" 2>&1 | tee -a "$log_file"
