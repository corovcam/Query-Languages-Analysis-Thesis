#!/bin/sh

set -eu

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

sqlite3 data/ecommerce.db < ./queries/schema.sql 2>&1 | tee logs/schema_"$timestamp".log && \
sqlite3 data/ecommerce.db < ./queries/data_1k.sql 2>&1 | tee logs/data_"$timestamp".log
