#!/bin/bash

set -euo pipefail

nodetool tablestats -H ecommerce > stats/table_stats_"$(date +"%Y-%m-%d_%s")".txt
