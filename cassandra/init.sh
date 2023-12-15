#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

cqlsh -f ./queries/schema.cql | tee logs/schema_"$timestamp".log

cqlsh -f ./queries/data_new.cql | tee logs/data_"$timestamp".log
