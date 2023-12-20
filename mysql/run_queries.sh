#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"
record_volume=1000

mkdir logs/queries/"$timestamp"

for i in {1..20}; do
    mysql --user=root --password=root -e "TRUNCATE performance_schema.events_statements_history_long;" ecommerce |& tee -a "$log_file"
    iteration_csv_file=logs/queries/"$timestamp"/iteration_"$i".csv
    echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" |& tee -a "$log_file"
    mysql --user=root --password=root --batch --unbuffered --skip-comments ecommerce < queries/query.sql > /dev/null 2>> "$log_file"
    mysql --user=root --password=root --batch \
        -e "SELECT SQL_TEXT as query, '$i' as iteration, TRUNCATE(TIMER_WAIT/1000000000000,6) as time_in_seconds FROM performance_schema.events_statements_history_long WHERE EVENT_NAME='statement/sql/select' AND SQL_TEXT<>'select @@version_comment limit 1';" ecommerce \
        2>> "$log_file" | \
        sed "s/^/mysql\t$record_volume\t/g" | sed "1 s/^.*$record_volume\t//" | sed '1 s/^/db\trecord_volume\t/' | sed 's/\\n/ /g' | tr -s ' ' | \
        tee -a "$iteration_csv_file"
done
