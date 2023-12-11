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

-- 1.4 Indexed Columns - Range Query

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
WHERE friendCount > 1
    ALLOW FILTERING;

-- 4. Unlimited Traversal (WITH RECURSIVE)

-- 4.1. Both way traversal

-- Find all direct and indirect relationships between people
SELECT *
FROM Person_Relationships;

-- 4.2. Shortest path

-- Find the shortest path between two people - NOT POSSIBLE IN CASSANDRA
-- Only by explicitly inserting each and every shortest path between all tuples of (person1id, person2id)
-- in a specific table Shortest_Paths_By_Person, etc.
-- I find it highly ineffective to use Cassandra for calculating shortest paths this way

-- 5. Optional Traversal

-- 5.1

-- Get a list of all people and their friend count (0 if they have no friends)
SELECT *
FROM Person;

-- 6. UNION

-- Get a list of contacts (email and phone) for both vendors and customers

SELECT *
FROM Contact;

-- 7. Intersection

-- Find common tags between posts and persons
-- Since Cassandra does not support INTERSECTION, we need to use a workaround
-- By using a SET of personIds and postIds, we insert a dummy value (-1) to each set which contains some value
-- (the reason for this is that Cassandra only supports CONTAINS operator)
SELECT tagId, value
FROM Tag
WHERE interestedPeople CONTAINS -1 AND postsTagged CONTAINS -1
    ALLOW FILTERING;
-- TODO: We can also create a secondary index on the "interestedPeople" and "postsTagged" columns to avoid ALLOW FILTERING

-- 8. Difference

-- Find people who have not made any orders

SELECT personId, firstName, lastName
FROM Orders_By_Person
WHERE orderedProducts CONTAINS -1
    ALLOW FILTERING;

-- 9. Sorting

-- 9.1 Non-Indexed Columns

-- In Cassandra, ORDER BY (ordering) is only allowed on the clustering columns of the PRIMARY KEY
-- therefore, the following query is not allowed:
-- SELECT *
-- FROM Product
-- ORDER BY brand;

-- 9.2 Indexed Columns

-- In Cassandra, without specifying the clustering columns, the results are returned in the order of the partition key
SELECT *
FROM Product;

-- 10. Distinct

-- Find unique combinations of product brands and the countries of the vendors selling those products

SELECT brand, country
FROM Vendor_Countries_By_Product_Brand;

-- 11. MapReduce

-- Find the number of orders per customer (only those who have made at least 1 order)

SELECT customerId, COUNT(*) AS orderCount
FROM Orders_By_Customer
GROUP BY customerId;