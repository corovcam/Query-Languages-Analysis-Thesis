SELECT "Customer" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Customer`
UNION
SELECT "Industry" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Industry`
UNION
SELECT "Order" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Order`
UNION
SELECT "Order_Contacts" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Order_Contacts`
UNION
SELECT "Order_Products" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Order_Products`
UNION
SELECT "Person" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Person`
UNION
SELECT "Person_Person" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Person_Person`
UNION
SELECT "Person_Tags" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Person_Tags`
UNION
SELECT "Post" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Post`
UNION
SELECT "Post_Tags" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Post_Tags`
UNION
SELECT "Product" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Product`
UNION
SELECT "Tag" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Tag`
UNION
SELECT "Type" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Type`
UNION
SELECT "Vendor" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Vendor`
UNION
SELECT "Vendor_Contacts" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Vendor_Contacts`
UNION
SELECT "Vendor_Products" AS table_name, COUNT(*) AS exact_row_count
FROM `ecommerce`.`Vendor_Products`;