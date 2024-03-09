#!/bin/bash

set -euo pipefail

npm install && tsc && node --max-old-space-size=16384 dist2/data-generator.js "$1"
