#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="../logs/neo4j-etl-tool_$timestamp.log"

# Requires JAVA_HOME to be set to a JDK 8 installation or higher
echo "Started at $(date +"%Y-%m-%d %T")" | tee -a "$log_file"
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
  --neo4j:password neo4j | tee -a "$log_file"
  