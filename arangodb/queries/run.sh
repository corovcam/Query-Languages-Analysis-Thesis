#!/bin/sh

arangosh < query.js | tee -a ../logs/output_"$(date +"%Y-%m-%d-%s")".log
