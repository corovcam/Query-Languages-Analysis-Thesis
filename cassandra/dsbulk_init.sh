#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%s")
log_file="logs/dsbulk_import_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Creating schema" |& tee -a "$log_file"
cqlsh -f ./queries/schema.cql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished creating schema" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing data from csv" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t "Order" -url csv/order.csv -m 'orderid, customerid, personid, firstname, lastname, gender, birthday, street, city, postalcode, personcountry, productid, asin, title, price, brand, imageurl, quantity, vendorid, vendorname, vendorcountry' -header false --connector.csv.quote '\"' |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t person_by_birthday_indexed -url csv/person_by_birthday_indexed.csv -m 'personid, firstname, lastname, gender, birthday, street, city, postalcode, country' -header false --connector.csv.quote '\"' |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished importing data from csv" |& tee -a "$log_file"

chmod 777 -R logs/LOAD*
