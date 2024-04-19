#!/bin/sh

# Use this to get the collection sizes of the ArangoDB database. (db size)

set -eu

arangosh --server.authentication false < queries/get_collection_sizes.js
