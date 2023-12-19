#!/bin/bash

cypher-shell --format plain "CALL apoc.export.cypher.all('/neo4j/queries/data.cypher', {format:'cypher-shell'})"
