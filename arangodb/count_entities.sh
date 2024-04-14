#!/bin/sh

set -eu

data_dir="dumps/data_512k"

for file in "$data_dir"/**/*.json; do
    fullFilename=$(basename "$file")
    filename=${fullFilename%.*}
    echo "$filename,$(wc -l < "$file")"
done
