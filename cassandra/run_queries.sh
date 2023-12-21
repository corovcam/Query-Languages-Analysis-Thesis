#!/bin/bash

set -euo pipefail

record_volume=1000

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
query_csv_file=logs/queries/query_results_"$timestamp".csv

echo "db,record_volume,query,iteration,time_in_seconds" | tee -a "$query_csv_file"

for file in queries/testing/*.cql; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    for i in {1..20}
    do
        printf "cassandra,%s,%s,%s," "$record_volume" "$filename" "$i" | tee -a "$query_csv_file"
        cqlsh -e "TRUNCATE system_traces.sessions;" |& tee -a "$log_file"
        echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" |& tee -a "$log_file"
        # Setting request-timeout to 300 seconds = 5 minutes
        cqlsh -k ecommerce -f "$file" --request-timeout=300 |& tee -a "$log_file"
        time_in_microseconds=$(cqlsh -e "SELECT duration FROM system_traces.sessions;" 2>> "$log_file" | sed -n '4p' | tr -d " \n\t\r")
        time_in_seconds=$(echo "print $time_in_microseconds/1000000" | perl)
        printf "%s\n" "$time_in_seconds" | tee -a "$query_csv_file"
    done
done
