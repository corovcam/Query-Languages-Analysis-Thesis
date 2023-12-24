#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%s")
data_file="data_256k"

cqlsh -f ./queries/schema.cql |& tee logs/schema_"$timestamp".log

cqlsh -f ./queries/"$data_file".cql |& tee logs/data_"$timestamp".log
