#!/bin/sh

# NOTE: ArangoDB can cause enourmous memory usage and sometimes causes Docker to kill the container and restart it. 
# To avoid this, you can reduce the memory footprint of ArangoDB by following the instructions in the link below:
# https://docs.arangodb.com/3.11/operations/administration/reduce-memory-footprint/
# Since we don't want to limit resources in our testing, we didn't apply any limits.

# NOTE: This also implies the script might be killed by the OS if the memory usage is too high. So repeat it again for queries not yet tested.

set -eu

record_volume=1024000 # NOTE: Change this for every experiment with different data volume

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
