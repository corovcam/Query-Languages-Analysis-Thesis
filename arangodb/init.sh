#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/import_$timestamp.log"
data_dir="dumps/data_128k" # NOTE: Change this to data dump directory
import_file_type="json" # data_256k+ dumps use jsonl format

echo "[$(date +"%Y-%m-%d %T")] Starting init" 2>&1 | tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Creating nodes" 2>&1 | tee -a "$log_file"
for file in "$data_dir"/nodes/*.json; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    echo "[$(date +"%Y-%m-%d %T")] Importing $filename" 2>&1 | tee -a "$log_file"
    arangoimport \
        --server.endpoint tcp://127.0.0.1:8529 \
        --server.authentication false \
        --collection "$filename" \
        --create-collection true \
        --create-collection-type document \
        --type "$import_file_type" \
        --file "$file" \
        --progress true \
        --overwrite true \
        2>&1 | tee -a "$log_file"
    echo "[$(date +"%Y-%m-%d %T")] Finished importing $filename" 2>&1 | tee -a "$log_file"
done
echo "[$(date +"%Y-%m-%d %T")] Finished creating nodes" 2>&1 | tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Creating edges" 2>&1 | tee -a "$log_file"
for file in "$data_dir"/edges/*.json; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    echo "[$(date +"%Y-%m-%d %T")] Importing $filename" 2>&1 | tee -a "$log_file"
    arangoimport \
        --server.endpoint tcp://127.0.0.1:8529 \
        --server.authentication false \
        --collection "$filename" \
        --create-collection true \
        --create-collection-type edge \
        --type "$import_file_type" \
        --file "$file" \
        --progress true \
        --overwrite true \
        2>&1 | tee -a "$log_file"
    echo "[$(date +"%Y-%m-%d %T")] Finished importing $filename" 2>&1 | tee -a "$log_file"
done
echo "[$(date +"%Y-%m-%d %T")] Finished creating edges" 2>&1 | tee -a "$log_file"
