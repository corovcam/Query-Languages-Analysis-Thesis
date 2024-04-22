#!/bin/sh

set -eu

record_volume=1024000 # NOTE: Change this to the tested record volume

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
query_csv_file=logs/queries/query_results_"$timestamp".csv

echo "db,record_volume,query,iteration,time_in_seconds" | tee -a "$query_csv_file"

echo "[$(date +"%Y-%m-%d %T")] Query testing started" 2>&1 | tee -a "$log_file"
for file in queries/testing/*.sql; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    i=1
    while [ "$i" -le 20 ]; do
        printf "sqlite,%s,%s,%s," "$record_volume" "$filename" "$i" | tee -a "$query_csv_file"
        echo "[$(date +"%Y-%m-%d %T")] Query $filename - iteration $i started" 2>&1 | tee -a "$log_file"
        # If query fails or timeout of 5 minutes (300 seconds) is reached, write -1 to csv file and continue with next query
        query_output=$(timeout 300 sqlite3 data/ecommerce.db < "$file" 2>> "$log_file") || \
            { echo "-1" | tee -a "$query_csv_file"; break; }
        echo "[$(date +"%Y-%m-%d %T")] Query $filename - iteration $i finished" 2>&1 | tee -a "$log_file"
        echo "$query_output" | tail -n 1 | sed -n 's/^.*real \([0-9]*\.[0-9]*\) .*$/\1/p' | tee -a "$query_csv_file"
        i=$((i+1))
    done
done
echo "[$(date +"%Y-%m-%d %T")] Query testing finished" 2>&1 | tee -a "$log_file"
