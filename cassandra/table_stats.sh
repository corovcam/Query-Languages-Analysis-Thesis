#!/bin/bash

# Use this to get the table statistics of the Cassandra database. (db size)

set -euo pipefail

nodetool tablestats -H ecommerce > stats/table_stats_"$(date +"%Y-%m-%d_%s")".txt
