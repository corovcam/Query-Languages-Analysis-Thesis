#!/bin/bash

set -euo pipefail

record_volume=1000

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
query_csv_file=logs/queries/query_results_"$timestamp".csv

mkdir logs/queries/"$timestamp"

echo "db,record_volume,query,iteration,time_in_seconds" | tee -a "$query_csv_file"

for file in queries/testing/*.cypher; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    for i in {1..20}; do
        echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" | tee -a "$log_file"
        printf "%s,%s,%s,%s," "neo4j" "$record_volume" "$filename" "$i" | tee -a "$query_csv_file"
        time_in_ms=$(cypher-shell --format plain < "$file" 2>> "$log_file" | tail -n 4 | head -n 1 | grep -o '[0-9]*' | tr -d '\n')
        time_in_seconds=$(echo "print $time_in_ms/1000" | perl)
        printf "%s\n" "$time_in_seconds" | tee -a "$query_csv_file"
    done
done
