#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="logs/cypher_dump_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Cypher dump started" |& tee -a "$log_file"
cypher-shell --format plain --log "logs/cypher_dump_verbose_$timestamp.log" "CALL apoc.export.cypher.all('/neo4j/queries/data_$timestamp.cypher', {format:'cypher-shell'})"
echo "[$(date +"%Y-%m-%d %T")] Cypher dump finished" |& tee -a "$log_file"
