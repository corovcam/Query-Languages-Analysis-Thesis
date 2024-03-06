#!/bin/bash

# Tested with Node 20.10

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/arangodb_transform_json_$timestamp.log"

{
  cd ./arangodb-json-transform
  npm install
  cd ..
} && \
{
  echo "[$(date +"%Y-%m-%d %T")] ArangoDB JSON documents transformation started." |& tee -a "$log_file"
  node --max-old-space-size=16384 ./arangodb-json-transform/transform-json.js |& tee -a "$log_file"
  echo "[$(date +"%Y-%m-%d %T")] ArangoDB JSON documents transformation finished." |& tee -a "$log_file"
}
