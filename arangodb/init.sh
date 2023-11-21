#!/bin/sh

# arangoimport \
#     --server.endpoint tcp://127.0.0.1:8529 \
#     --server.authentication false \
#     --collection "products" \
#     --create-collection true \
#     --type json \
#     --file data/products.json \
#     --progress true \
#     --overwrite true \
#     | tee -a logs/import.log

# arangoimport \
#     --server.endpoint tcp://127.0.0.1:8529 \
#     --server.authentication false \
#     --collection "vendors" \
#     --create-collection true \
#     --type json \
#     --file data/vendors.json \
#     --progress true \
#     --overwrite true \
#     | tee -a logs/import.log

# arangoimport \
#     --server.endpoint tcp://127.0.0.1:8529 \
#     --server.authentication false \
#     --collection "edges" \
#     --create-collection true \
#     --create-collection-type edge \
#     --type json \
#     --file data/rels.json \
#     --progress true \
#     --overwrite true \
#     | tee -a logs/import.log

for file in data/nodes/*.json; do
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
        | tee -a logs/import.log
done

for file in data/edges/*.json; do
    fullFilename=$(basename "$file")
    echo "$fullFilename"
    filename=${fullFilename%.*}
    echo "$filename"
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
        | tee -a logs/import.log
done