#!/bin/bash

cqlsh -f ./queries/schema.cql | tee logs/schema.log

cqlsh -f ./queries/data.cql | tee logs/data.log
