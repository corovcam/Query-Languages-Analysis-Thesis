#!/bin/bash

# Tested with Node 20.8.0

set -euo pipefail

npm install && node --max-old-space-size=16384 data-generator-old.js "$@"
