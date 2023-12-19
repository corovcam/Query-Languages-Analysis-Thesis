#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"

mkdir logs/queries/"$timestamp"

for file in queries/testing/*.cypher; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    query_log_file=logs/queries/"$timestamp"/query_"$filename".log
    for i in {1..20}; do
        echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" | tee -a "$query_log_file"
        cypher-shell --format plain < "$file" 2>> "$log_file" | tail -n 9 | tee -a "$query_log_file"
    done
done
