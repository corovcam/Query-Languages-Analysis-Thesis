#!/bin/bash

# Use this script to count the number of rows in each table of the Cassandra database.

# Run outside container

set -euo pipefail

timestamp=$(date +"%Y-%m-%d_%s")
log_file="logs/table_row_counts_$timestamp.log"

counts_csv_file="logs/table_row_counts_$timestamp.csv"

echo "table,row_count" >> "$counts_csv_file"

echo "[$(date +"%Y-%m-%d %T")] Counting table rows" |& tee -a "$log_file"
echo "Contact,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t contact |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Order,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t "Order" |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Orders_by_customer,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t orders_by_customer |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Orders_by_person,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t orders_by_person |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Orders_by_product,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t orders_by_product |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Person,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t person |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Person_by_birthday_indexed,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t person_by_birthday_indexed |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Product,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t product |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Products_by_brand,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t products_by_brand |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Tag,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t tag |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Vendor,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t vendor |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Vendor_contacts_by_order_contact,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t vendor_contacts_by_order_contact |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "Vendor_countries_by_product_brand,$(java -jar dsbulk/dsbulk-1.11.0.jar count -k ecommerce -t vendor_countries_by_product_brand |& tee -a "$log_file" | tail -1)" | tee -a "$counts_csv_file"
echo "[$(date +"%Y-%m-%d %T")] Finished counting table rows" |& tee -a "$log_file"

chmod 777 -R logs/COUNT*
