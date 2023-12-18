#!/bin/sh

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

cypher-shell --format plain --log logs/export_"$timestamp".log < ./queries/export.cypher
