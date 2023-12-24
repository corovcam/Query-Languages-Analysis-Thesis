#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
data_file="data_256k"

mysql --user=root --password=root ecommerce < ./queries/schema.sql |& tee logs/schema_"$timestamp".log && \
mysql --user=root --password=root ecommerce < ./queries/procedures.sql |& tee -a logs/schema_"$timestamp".log && \
mysql --max_allowed_packet=1G --user=root --password=root ecommerce < ./queries/$data_file.sql |& tee logs/data_"$timestamp".log

mysql --user=root --password=root ecommerce < ./queries/setup_profiling.sql |& tee logs/data_"$timestamp".log
