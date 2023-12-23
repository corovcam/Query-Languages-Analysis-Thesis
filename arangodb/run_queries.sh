#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
query_result_file="logs/queries/query_result_$timestamp.log"

arangosh \
  --server.authentication false \
  --console.audit-file \
  --server.request-timeout 300 \
  "$query_result_file" < queries/query_testing.js 2>&1 | tee -a "$log_file"
