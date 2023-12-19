#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"

mkdir logs/queries/"$timestamp"

i=1
while [ "$i" -le 20 ]; do
    iteration_log_file=logs/queries/"$timestamp"/iteration_"$i".log
    echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" 2>&1 | tee -a "$log_file"
    sqlite3 data/ecommerce.db < queries/query.sql 2>> "$log_file" | tee -a "$iteration_log_file"
    i=$((i+1))
done
