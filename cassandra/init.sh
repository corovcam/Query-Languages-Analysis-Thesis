#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%s")

cqlsh -f ./queries/schema.cql | tee logs/schema_"$timestamp".log

cqlsh -f ./queries/data_1k.cql | tee logs/data_"$timestamp".log
