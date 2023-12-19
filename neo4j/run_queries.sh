#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

for i in {1..20}
do
    log_file="../logs/query_$timestamp-run$i.log"
    echo "Iteration $i, started at $(date +"%Y-%m-%d %T")" | tee -a "$log_file"
    cypher-shell --format plain -f ./query.cql | tee -a "$log_file"
done
