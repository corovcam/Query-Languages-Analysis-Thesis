SELECT "Customer" AS table_name, COUNT(*) AS exact_row_count
FROM `Customer`
UNION
SELECT "Industry" AS table_name, COUNT(*) AS exact_row_count
FROM `Industry`
UNION
SELECT "Order" AS table_name, COUNT(*) AS exact_row_count
FROM `Order`
UNION
SELECT "Order_Contacts" AS table_name, COUNT(*) AS exact_row_count
FROM `Order_Contacts`
UNION
SELECT "Order_Products" AS table_name, COUNT(*) AS exact_row_count
FROM `Order_Products`
UNION
SELECT "Person" AS table_name, COUNT(*) AS exact_row_count
FROM `Person`
UNION
SELECT "Person_Person" AS table_name, COUNT(*) AS exact_row_count
FROM `Person_Person`
UNION
SELECT "Person_Tags" AS table_name, COUNT(*) AS exact_row_count
FROM `Person_Tags`
UNION
SELECT "Post" AS table_name, COUNT(*) AS exact_row_count
FROM `Post`
UNION
SELECT "Post_Tags" AS table_name, COUNT(*) AS exact_row_count
FROM `Post_Tags`
UNION
SELECT "Product" AS table_name, COUNT(*) AS exact_row_count
FROM `Product`
UNION
SELECT "Tag" AS table_name, COUNT(*) AS exact_row_count
FROM `Tag`
UNION
SELECT "Type" AS table_name, COUNT(*) AS exact_row_count
FROM `Type`
UNION
SELECT "Vendor" AS table_name, COUNT(*) AS exact_row_count
FROM `Vendor`
UNION
SELECT "Vendor_Contacts" AS table_name, COUNT(*) AS exact_row_count
FROM `Vendor_Contacts`
UNION
SELECT "Vendor_Products" AS table_name, COUNT(*) AS exact_row_count
FROM `Vendor_Products`;