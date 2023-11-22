#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%s")

mongosh --quiet "mongodb://localhost:27017/ecommerce" < query.js | tee -a ../logs/output_"$timestamp".log
