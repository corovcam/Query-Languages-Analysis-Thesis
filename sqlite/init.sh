#!/bin/sh

sqlite3 data/ecommerce.db < ./queries/schema.sql

sqlite3 data/ecommerce.db < ./queries/data.sql
