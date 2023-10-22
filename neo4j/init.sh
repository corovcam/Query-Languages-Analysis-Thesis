#!/bin/bash

cypher-shell --format plain --log logs/logs.log < ./queries/data.cypher > logs/out.log 2> logs/err.log
