#!/bin/sh

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir logs/queries/"$timestamp"

for file in queries/testing/*.cypher; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    log_file=logs/queries/"$timestamp"/query_"$filename".log
    for i in {1..20}; do
        echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" | tee -a "$log_file"
        mysql --user=root --password=root ecommerce < $file | tee -a "$log_file"
    done
done
