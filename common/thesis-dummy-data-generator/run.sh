#!/bin/bash

# Tested with Node 20.8.0

set -euo pipefail

npm install && tsc && node --max-old-space-size=16384 dist/data-generator.js "$1"
