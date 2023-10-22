#!/bin/sh

mysql --user=test --password=test ecommerce < ./queries/schema.sql

mysql --user=test --password=test ecommerce < ./queries/data.sql