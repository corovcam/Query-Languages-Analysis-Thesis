#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/database_dump_$timestamp.log"

# Must be absolute path
dump_dir="$HOME/Query-Languages-Analysis-Thesis/neo4j/dumps/data_256k"

# https://neo4j.com/docs/operations-manual/current/docker/dump-load/
echo "[$(date +"%Y-%m-%d %T")] Database load started" |& tee -a "$log_file"
docker run --interactive --tty --rm \
    --volume=query-languages-analysis-thesis_neo4j_data:/data \
    --volume="$dump_dir":/backups \
    neo4j/neo4j-admin:5.12.0 \
neo4j-admin database load neo4j --from-path=/backups || echo "[$(date +"%Y-%m-%d %T")] Database load failed" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Database load finished" |& tee -a "$log_file"
