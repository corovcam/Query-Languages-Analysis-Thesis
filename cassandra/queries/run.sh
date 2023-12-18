#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

for i in {1..50}
do
    cqlsh -f ./query.cql | tee ../logs/query_"$timestamp"_run"$i".log
done
