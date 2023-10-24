#!/bin/sh

arangoimport \
    --server.endpoint tcp://127.0.0.1:8529 \
    --server.authentication false \
    --collection "product" \
    --create-collection true \
    --type json \
    --file data/product.json \
    --progress true \
    --overwrite true \
    | tee -a logs/import.log

arangoimport \
    --server.endpoint tcp://127.0.0.1:8529 \
    --server.authentication false \
    --collection "vendor" \
    --create-collection true \
    --type json \
    --file data/vendor.json \
    --progress true \
    --overwrite true \
    | tee -a logs/import.log

arangoimport \
    --server.endpoint tcp://127.0.0.1:8529 \
    --server.authentication false \
    --collection "edges" \
    --create-collection true \
    --create-collection-type edge \
    --type json \
    --file data/rels.json \
    --progress true \
    --overwrite true \
    | tee -a logs/import.log
