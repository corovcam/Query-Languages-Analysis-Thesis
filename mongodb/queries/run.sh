#!/bin/bash

mongosh --quiet "mongodb://localhost:27017/ecommerce" < query.js | tee -a ../logs/output.log
