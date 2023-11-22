#!/bin/sh

cypher-shell --format plain --log logs/export_"$(date +"%Y-%m-%d-%s")".log < ./export.cypher
