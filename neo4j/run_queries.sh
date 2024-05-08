#!/bin/bash

set -euo pipefail

record_volume=1024000 # NOTE: Change this to the desired record volume

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
query_csv_file=logs/queries/query_results_"$timestamp".csv

echo "db,record_volume,query,iteration,time_in_seconds" | tee -a "$query_csv_file"

echo "[$(date +"%Y-%m-%d %T")] Query testing started" |& tee -a "$log_file"

for file in queries/testing/*.cypher; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    for i in {1..20}; do
        echo "[$(date +"%Y-%m-%d %T")] Query $filename, Iteration $i started" |& tee -a "$log_file"

        printf "%s,%s,%s,%s," "neo4j" "$record_volume" "$filename" "$i" | tee -a "$query_csv_file"
        time_in_ms=$(cypher-shell --format plain --log "logs/query_neo4j_verbose_$timestamp.log" < "$file" 2>> "$log_file" | tail -n 4 | head -n 1 | grep -o '[0-9]*' | tr -d '\n') || \
            { echo "-1" | tee -a "$query_csv_file" && break; } # If query fails, write -1 to csv file and continue with next query
        time_in_seconds=$(echo "print $time_in_ms/1000" | perl)
        echo "$time_in_seconds" | tee -a "$query_csv_file"

        echo "[$(date +"%Y-%m-%d %T")] Query $filename, Iteration $i finished" |& tee -a "$log_file"
    done
done

echo "[$(date +"%Y-%m-%d %T")] Query testing finished" |& tee -a "$log_file"
