#!/bin/sh

arangosh < query.js | tee -a ../logs/output.log
