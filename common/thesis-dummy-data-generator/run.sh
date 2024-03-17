#!/bin/bash

set -euo pipefail

npm install && tsc && node --max-old-space-size=16384 dist/data-generator.js "$1"
