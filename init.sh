#!/bin/sh

# Run init.sh in all containers
for DB_NAME in "$@" ; do
    CONTAINER_NAME="query-languages-analysis-thesis-$DB_NAME-1"
    docker exec "$CONTAINER_NAME" sh -c "chmod 777 -R ./ && ./init.sh"
done
