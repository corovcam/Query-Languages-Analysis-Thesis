#!/bin/sh

set -eu

arangosh --server.authentication false < queries/get_collection_sizes.js
