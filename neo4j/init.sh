#!/bin/bash


timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

cypher-shell --format plain < ./queries/db_reset.cypher | tee logs/schema_"$timestamp".log && \
cypher-shell --format plain < ./queries/data_1k.cypher | tee logs/data_"$timestamp".log && \
cypher-shell --format plain < ./queries/transform_data.cypher | tee logs/transform-data_"$timestamp".log
