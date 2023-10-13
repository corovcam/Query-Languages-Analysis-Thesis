#!/bin/bash

set -ueo pipefail

# Run init.sh in all containers
for CONTAINER_NAME in "$@" ; do
    docker exec "$CONTAINER_NAME" /bin/sh -c "./init.sh"
done
