#!/bin/bash

set -ueo pipefail

# Run init.sh in all containers
for DB_NAME in "$@" ; do
    CONTAINER_NAME="query-languages-analysis-thesis-$DB_NAME-1"
    docker exec "$CONTAINER_NAME" /bin/bash -c "./init.sh"
done
