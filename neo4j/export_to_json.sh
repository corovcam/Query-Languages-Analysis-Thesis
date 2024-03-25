#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/export_$timestamp.log"

# Sometimes the export fails because the directories are not writable inside the container.
chmod 777 -R exports/nodes exports/edges

echo "[$(date +"%Y-%m-%d %T")] JSON export started" |& tee -a "$log_file"
cypher-shell --format plain --log "logs/export_verbose_$timestamp.log" < ./queries/export_to_json.cypher |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] JSON export finished" |& tee -a "$log_file"
