#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

mysql --user=root --password=root ecommerce < ./queries/schema.sql |& tee logs/schema_"$timestamp".log && \
mysql --user=root --password=root ecommerce < ./queries/procedures.sql |& tee -a logs/schema_"$timestamp".log && \
mysql --user=root --password=root ecommerce < ./queries/data_1k.sql |& tee logs/data_"$timestamp".log
