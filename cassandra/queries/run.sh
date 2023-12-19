#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="../logs/query_$timestamp.log"

cqlsh -e "TRUNCATE system_traces.sessions;" | tee -a "$log_file"

for i in {1..20}
do
    echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" | tee -a "$log_file"
    # Setting request-timeout to 300 seconds = 5 minutes
    cqlsh -f ./query.cql --request-timeout=300 | tee -a "$log_file"
done

cqlsh -e "COPY system_traces.sessions TO '../logs/queries/sessions_$timestamp.csv' WITH HEADER = TRUE;" | tee -a "$log_file"
