#!/bin/bash

set -euo pipefail

record_volume=4000

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
query_csv_file=logs/queries/query_results_"$timestamp".csv

echo "db,record_volume,query,iteration,time_in_seconds" | tee -a "$query_csv_file"

for file in queries/testing/*.sql; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    for i in {1..20}; do
        printf "mysql,%s,%s,%s," "$record_volume" "$filename" "$i" | tee -a "$query_csv_file"
        mysql --user=root --password=root -e "TRUNCATE performance_schema.events_statements_history_long;" ecommerce |& tee -a "$log_file"
        echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" |& tee -a "$log_file"
        mysql --user=root --password=root --batch --unbuffered --skip-comments ecommerce < "$file" > /dev/null 2>> "$log_file"
        mysql -sN --user=root --password=root --batch \
            -e "SELECT TRUNCATE(TIMER_WAIT/1000000000000,6) FROM performance_schema.events_statements_history_long WHERE EVENT_NAME='statement/sql/select' AND SQL_TEXT<>'select @@version_comment limit 1';" ecommerce \
            2>> "$log_file" | tee -a "$query_csv_file"
    done
done
