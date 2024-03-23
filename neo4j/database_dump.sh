#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/database_dump_$timestamp.log"

mkdir -p "dumps/$timestamp"
chmod -R 777 "dumps/$timestamp"

# cd /var/lib/neo4j/bin || { echo "[$(date +"%Y-%m-%d %T")] Failed to change directory to /var/lib/neo4j/bin" |& tee -a "$log_file"; exit 1; }

# https://neo4j.com/docs/operations-manual/current/docker/dump-load/
echo "[$(date +"%Y-%m-%d %T")] Database dump started" |& tee -a "$log_file"
docker run --interactive --tty --rm \
  --volume=query-languages-analysis-thesis_neo4j_data:/data \
  --volume="$HOME"/Query-Languages-Analysis-Thesis/neo4j/dumps/"$timestamp":/backups \
  neo4j/neo4j-admin:5.12.0 \
neo4j-admin database dump neo4j --to-path=/backups || echo "[$(date +"%Y-%m-%d %T")] Database dump failed" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Database dump finished" |& tee -a "$log_file"
