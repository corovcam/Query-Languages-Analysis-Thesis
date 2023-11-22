#!/bin/bash

cypher-shell --format plain --log logs/init_"$(date +"%Y-%m-%d-%s")".log < ./queries/data.cypher > logs/out_"$(date +"%Y-%m-%d-%s")".log 2> logs/err_"$(date +"%Y-%m-%d-%s")".log
