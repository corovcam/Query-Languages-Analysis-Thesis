#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"

mkdir logs/queries/"$timestamp"

for file in queries/testing/*.sql; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    query_csv_file=logs/queries/"$timestamp"/query_"$filename".csv
    i=1
    while [ "$i" -le 20 ]; do
        printf "\"%s\",%s,\"$(date +"%Y-%m-%d %T")\",\"" "$filename" "$i" | tee -a "$query_csv_file"
        sqlite3 data/ecommerce.db < "$file" 2>> "$log_file" | tail -n 1 | tr -d '\n' | tee -a "$query_csv_file"
        printf "\"\n" | tee -a "$query_csv_file"
        i=$((i+1))
    done
done
