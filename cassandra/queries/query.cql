use ecommerce;

-- 1. Selection, Projection, Source (of data)

-- 1.1 Non-Indexed Columns

-- Select vendor with the name "Vendor A"
SELECT vendorId, name
FROM Vendor
WHERE name = 'Vendor A'
    ALLOW FILTERING;

-- 1.2 Non-Indexed Columns - Range Query

-- Select people born between 1980-01-01 and 1990-12-31
SELECT personId, firstName, lastName, birthday
FROM Person
WHERE birthday >= '1980-01-01'
  AND birthday <= '1990-12-31'
    ALLOW FILTERING;

-- 1.3 Indexed Columns

-- Select vendor with the ID 1
SELECT vendorId, name
FROM Vendor
WHERE vendorId = 1;

-- Select people born between 1980-01-01 and 1990-12-31 (using index)
-- TODO: Check if the "clustering index" on "birthday" is really used if performing a query without
--  specifying the partition key (all partitions are scanned)
SELECT personId, firstName, lastName, birthday
FROM Person_By_Birthday_Indexed
WHERE birthday >= '1980-01-01'
  AND birthday <= '1990-12-31'
    ALLOW FILTERING;

-- 2. Aggregation

-- 2.1 COUNT

-- Count the number of products per brand
SELECT brand, COUNT(*) AS productCount
FROM Products_By_Brand
GROUP BY brand;

-- 2.2 MAX

-- Find the most expensive product per brand
SELECT brand, MAX(price) AS maxPrice
FROM Products_By_Brand
GROUP BY brand;

-- 3. Join (not supported in Cassandra)

-- 3.1

-- Return all Orders and Vendors sharing the same Contact typeId
SELECT *
FROM Order_Vendor_Contacts_By_Contact_Type;

-- 3.2

SELECT *
FROM Orders_By_Product;

-- 3.3 Complex Join 1

-- Complex query to return Order details
SELECT *
FROM "Order";


-- 3.4 Complex Join 2 (having more than 1 friend)

SELECT *
FROM Person
WHERE knowsPeople CONTAINS 1 -- Does not work, because "knowsPeople" is a set, and there literally no functions on collections in Cassandra
    ALLOW FILTERING;

