#!/bin/bash

mongoimport --db ecommerce --collection vendors --drop --file ./data/vendor.json --jsonArray | tee -a logs/import.log

mongoimport --db ecommerce --collection products --drop --file ./data/product.json --jsonArray | tee -a logs/import.log
