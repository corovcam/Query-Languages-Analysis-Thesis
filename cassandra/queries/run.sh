#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

cqlsh -f ./queries/query.cql | tee ../logs/query_"$timestamp".log
