#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/cassandra_export_to_csv_$timestamp.log"

mkdir -p exports
chmod -R 777 exports

echo "[$(date +"%Y-%m-%d %T")] Exporting to CSV" |& tee -a "$log_file"
mysql --user=root --password=root ecommerce < ./queries/cassandra_export_to_csv.sql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished exporting to CSV" |& tee -a "$log_file"

chmod -R 777 exports
