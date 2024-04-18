#!/bin/sh

set -eu

# Only JSON Lines format is supported for now
data_dir="dumps/data_128k"

for file in "$data_dir"/**/*.json; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    echo "$filename,$(wc -l < "$file")"
done
