#!/bin/bash

# 1. Remove neo4j service container 
# 2. Run this outside neo4j container

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/database_dump_$timestamp.log"

# Must be absolute path
dump_dir="$HOME/Query-Languages-Analysis-Thesis/neo4j/dumps/data_128k" # NOTE: Change this to the directory where the dump will be located

mkdir -p "$dump_dir"
chmod -R 777 "$dump_dir"

# https://neo4j.com/docs/operations-manual/current/docker/dump-load/
echo "[$(date +"%Y-%m-%d %T")] Database dump started" |& tee -a "$log_file"
docker run --interactive --tty --rm \
  --volume=query-languages-analysis-thesis_neo4j_data:/data \
  --volume="$dump_dir":/backups \
  neo4j/neo4j-admin:5.12.0 \
neo4j-admin database dump neo4j --to-path=/backups || echo "[$(date +"%Y-%m-%d %T")] Database dump failed" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Database dump finished" |& tee -a "$log_file"
