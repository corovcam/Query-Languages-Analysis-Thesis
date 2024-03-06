#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
query_result_file="logs/queries/query_result_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Starting query testing" 2>&1 | tee -a "$log_file"
arangosh \
  --server.authentication false \
  --console.audit-file \
  --server.request-timeout 300 \
  "$query_result_file" < queries/query_testing.js 2>&1 | tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished query testing" 2>&1 | tee -a "$log_file"
