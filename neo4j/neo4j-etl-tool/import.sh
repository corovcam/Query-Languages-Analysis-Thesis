#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="/neo4j/logs/neo4j-etl-tool_$timestamp.log"

# export NEO4J_HOME=/var/lib/neo4j
# Requires JAVA_HOME to be set to a JDK 8 installation or higher
# export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
# echo "[$(date +"%Y-%m-%d %T")] Set \$JAVA_HOME variable to $JAVA_HOME" |& tee -a "$log_file"

# NOTE: Neo4j instance must be stopped first before proceeding with this script
# If you get an error like "WARNING: Neo4j is running! You can run neo4j-import tool only if the database is offline"
# then you need to stop the Neo4j instance first (sometimes twice in a row):
# `neo4j stop`

echo "[$(date +"%Y-%m-%d %T")] Neo4j ETl Tool started" |& tee -a "$log_file"
./neo4j-etl-cli-1.6.0/bin/neo4j-etl export \
  --debug \
  --mapping-file mysql_ecommerce_mapping.json \
  --rdbms:password root \
  --rdbms:user root \
  --rdbms:url "jdbc:mysql://mysql:3306/ecommerce?autoReconnect=true&useSSL=false&useCursorFetch=true&allowPublicKeyRetrieval=true" \
  --options-file import-tool-options.json \
  --using bulk:neo4j-import \
  --csv-directory "/neo4j/neo4j-etl-tool/tmp/$timestamp" \
  --import-tool "$NEO4J_HOME/bin" \
  --destination /data/databases/neo4j/ \
  --force \
  --quote '"' \
  --neo4j:url neo4j://localhost:7687 \
  --neo4j:user neo4j \
  --neo4j:password neo4j |& tee -a "$log_file" || echo "[$(date +"%Y-%m-%d %T")] Neo4j ETL Tool failed" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Neo4j ETL Tool finished" |& tee -a "$log_file"

chmod -R 777 /neo4j/neo4j-etl-tool/tmp || echo "[$(date +"%Y-%m-%d %T")] Failed to change permissions for /neo4j/neo4j-etl-tool/tmp/$timestamp" |& tee -a "$log_file"

# Preprocess the config file to remove the first two lines - the new neo4j-admin import does not support them
sed -i '1,2d' /neo4j/neo4j-etl-tool/tmp/"$timestamp"/csv-001/neo4j-admin-import-params

cd "$NEO4J_HOME/bin" || { echo "[$(date +"%Y-%m-%d %T")] Failed to change directory to $NEO4J_HOME" |& tee -a "$log_file"; exit 1; }

echo "[$(date +"%Y-%m-%d %T")] Neo4j bulk import started" |& tee -a "$log_file"
# Could be maybe better to use something like this to import the data outside of docker container(to avoid stopping neo4j multiple times):
# docker run --interactive --tty --rm \
#     --volume=query-languages-analysis-thesis_neo4j_data:/data \
#     --volume=../.:/neo4j \
#     neo4j/neo4j-admin:5.12.0 \
# ./neo4j-admin database import full --verbose --overwrite-destination @/neo4j/neo4j-etl-tool/tmp/"$timestamp"/csv-001/neo4j-admin-import-params |& tee -a "$log_file" || echo "[$(date +"%Y-%m-%d %T")] Neo4j bulk import failed" |& tee -a "$log_file"
./neo4j-admin database import full --verbose --overwrite-destination @/neo4j/neo4j-etl-tool/tmp/"$timestamp"/csv-001/neo4j-admin-import-params |& tee -a "$log_file" || echo "[$(date +"%Y-%m-%d %T")] Neo4j bulk import failed" |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Neo4j bulk import finished" |& tee -a "$log_file"
