#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="../logs/neo4j-etl-tool_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Neo4j ETl Tool started" |& tee -a "$log_file"

# Requires JAVA_HOME to be set to a JDK 8 installation or higher
./neo4j-etl-cli-1.6.0/bin/neo4j-etl export \
  --mapping-file mysql_ecommerce_mapping.json \
  --rdbms:password test \
  --rdbms:user test \
  --rdbms:url "jdbc:mysql://localhost:3306/ecommerce?autoReconnect=true&useSSL=false&useCursorFetch=true&allowPublicKeyRetrieval=true" \
  --options-file import-tool-options.json \
  --using cypher:fromSQL \
  --unwind-batch-size 1000 \
  --tx-batch-size 10000 \
  --neo4j:url neo4j://localhost:7687 \
  --neo4j:user neo4j \
  --neo4j:password neo4j |& tee -a "$log_file" || echo "[$(date +"%Y-%m-%d %T")] Neo4j ETL Tool failed" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Neo4j ETL Tool finished" |& tee -a "$log_file"
