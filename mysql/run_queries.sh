#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"

mkdir logs/queries/"$timestamp"

for i in {1..20}; do
    mysql --user=root --password=root -e "TRUNCATE performance_schema.events_statements_history_long;" ecommerce |& tee -a "$log_file"
    iteration_csv_file=logs/queries/"$timestamp"/iteration_"$i".csv
    echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" |& tee -a "$log_file"
    mysql --user=root --password=root --batch --unbuffered --skip-comments ecommerce < queries/query.sql > /dev/null 2>> "$log_file"
    mysql --user=root --password=root --batch \
        -e "SELECT EVENT_ID, TRUNCATE(TIMER_WAIT/1000000000000,6) as Duration, SQL_TEXT FROM performance_schema.events_statements_history_long;" ecommerce \
        2>> "$log_file" | tee -a "$iteration_csv_file"
done
