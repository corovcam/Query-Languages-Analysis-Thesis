#!/bin/bash

mongoimport --db ecommerce --collection orders --drop --file ./data/orders.json --jsonArray | tee -a logs/import.log

mongoimport --db ecommerce --collection people --drop --file ./data/people.json --jsonArray | tee -a logs/import.log

mongoimport --db ecommerce --collection vendors --drop --file ./data/vendors.json --jsonArray | tee -a logs/import.log
