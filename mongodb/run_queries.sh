#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/query_$timestamp.log"

mongosh --quiet --eval 'config.set("displayBatchSize", 1000)' "mongodb://localhost:27017/ecommerce" < queries/query.js | tee -a "$log_file"
