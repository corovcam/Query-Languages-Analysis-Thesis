#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

data_dir="data_4k"

for file in "$data_dir"/nodes/*.json; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    arangoimport \
        --server.endpoint tcp://127.0.0.1:8529 \
        --server.authentication false \
        --collection "$filename" \
        --create-collection true \
        --create-collection-type document \
        --type json \
        --file "$file" \
        --progress true \
        --overwrite true \
        2>&1 | tee -a logs/import_"$timestamp".log
done

for file in "$data_dir"/edges/*.json; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    arangoimport \
        --server.endpoint tcp://127.0.0.1:8529 \
        --server.authentication false \
        --collection "$filename" \
        --create-collection true \
        --create-collection-type edge \
        --type json \
        --file "$file" \
        --progress true \
        --overwrite true \
        2>&1 | tee -a logs/import_"$timestamp".log
done
