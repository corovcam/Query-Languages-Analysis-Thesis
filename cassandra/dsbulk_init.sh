#!/bin/bash

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%s")
data_dir="dumps/data_256k"
log_file="logs/dsbulk_import_$timestamp.log"

echo "[$(date +"%Y-%m-%d %T")] Creating schema" |& tee -a "$log_file"
cqlsh -f ./queries/schema.cql |& tee -a "$log_file"
echo "[$(date +"%Y-%m-%d %T")] Finished creating schema" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing data from csv" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Vendor table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t vendor -url "$data_dir"/vendor.csv -header false --connector.csv.quote '\"' \
  -m 'vendorid, name, country' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Vendor table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Person table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t person -url "$data_dir"/person.csv -header false --connector.csv.quote '\"' \
  -m 'personid, firstname, lastname, gender, birthday, street, city, postalcode, country, friendcount' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Person table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Person_by_birthday_indexed table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t person_by_birthday_indexed -url "$data_dir"/person_by_birthday_indexed.csv -header false --connector.csv.quote '\"' \
  -m 'personid, firstname, lastname, gender, birthday, street, city, postalcode, country' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Person_by_birthday_indexed table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Products_By_Brand table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t products_by_brand -url "$data_dir"/product.csv -header false --connector.csv.quote '\"' \
  -m 'productid, asin, title, price, brand, imageurl' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Products_By_Brand table" |& tee -a "$log_file"

# Dropped in 4k+ experiments
# echo "[$(date +"%Y-%m-%d %T")] Importing Vendor_Contacts_By_Order_Contact table" |& tee -a "$log_file"
# java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t vendor_contacts_by_order_contact -url "$data_dir"/vendor_contacts_by_order_contact.csv -header false --connector.csv.quote '\"' \
#   -m 'typeid, orderid, ordercontactvalue, vendorid, vendorcontactvalue' |& tee -a "$log_file"
# echo "[$(date +"%Y-%m-%d %T")] Finished importing Vendor_Contacts_By_Order_Contact table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Orders_By_Product table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t orders_by_product -url "$data_dir"/orders_by_product.csv -header false --connector.csv.quote '\"' \
  -m 'productid, asin, title, price, brand, imageurl, orderid, quantity' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Orders_By_Product table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Order table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t "Order" -url "$data_dir"/order.csv -header false --connector.csv.quote '\"' \
  -m 'orderid, customerid, personid, firstname, lastname, gender, birthday, street, city, postalcode, personcountry, productid, asin, title, price, brand, imageurl, quantity, vendorid, vendorname, vendorcountry' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Order table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Contact table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t contact -url "$data_dir"/contact.csv -header false --connector.csv.quote '\"' \
  -m 'entitytype, entityid, entityname, contacttype, contactvalue' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Contact table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Tag table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t tag -url "$data_dir"/tag.csv -header false --connector.csv.quote '\"' \
  -m 'tagid, value, interestedpeople, poststagged' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Tag table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Orders_By_Person table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t orders_by_person -url "$data_dir"/orders_by_person.csv -header false --connector.csv.quote '\"' \
  -m 'personid, firstname, lastname, orderscreated' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Orders_By_Person table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Product table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t product -url "$data_dir"/product.csv -header false --connector.csv.quote '\"' \
  -m 'productid, asin, title, price, brand, imageurl' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Product table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Vendor_Countries_By_Product_Brand table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t vendor_countries_by_product_brand -url "$data_dir"/vendor_countries_by_product_brand.csv -header false --connector.csv.quote '\"' \
  -m 'brand, country' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Vendor_Countries_By_Product_Brand table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Importing Orders_By_Customer table" |& tee -a "$log_file"
java -jar dsbulk/dsbulk-1.11.0.jar load -k ecommerce -t orders_by_customer -url "$data_dir"/orders_by_customer.csv -header false --connector.csv.quote '\"' \
  -m 'customerid, orderid' |& tee -a "$log_file" || true
echo "[$(date +"%Y-%m-%d %T")] Finished importing Orders_By_Customer table" |& tee -a "$log_file"

echo "[$(date +"%Y-%m-%d %T")] Finished importing data from csv" |& tee -a "$log_file"

chmod 777 -R logs/LOAD*
