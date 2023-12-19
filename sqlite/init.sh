#!/bin/sh

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

sqlite3 data/ecommerce.db < ./queries/schema.sql |& tee logs/schema_"$timestamp".log && \
sqlite3 data/ecommerce.db < ./queries/data_1k.sql |& tee logs/data_"$timestamp".log
