#!/bin/bash

set -euo pipefail

npm install && node --max-old-space-size=16384 src/data-generator.js "$1"
