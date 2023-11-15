-- 1. Selection, Projection, Source (of data)

-- 1.1 Non-Indexed Columns

SELECT vendorId, name
FROM Vendor
WHERE name = "Vendor A";

-- 1.2 Indexed Columns

SELECT vendorId, name
FROM Vendor
WHERE VendorId = 1;

-- 2. Aggregation

-- 2.1 COUNT

SELECT brand, COUNT(*) AS productCount
FROM Product
GROUP BY brand;
-- HAVING AVG(price) > 1;

-- 2.2 MAX

SELECT brand, MAX(price) AS maxPrice
FROM Product
GROUP BY brand;

-- 3. Join

-- 3.1 Non-Indexed Columns ??

SELECT *
FROM Product P
         INNER JOIN Order_Products OP on P.productId = OP.productId;

-- 3.2 Indexed Columns

SELECT *
FROM Product P
         INNER JOIN Order_Products OP on P.productId = OP.productId;

-- 3.3 Complex Join 1

SELECT *
FROM Product P
         INNER JOIN Order_Products OP on P.productId = OP.productId
         INNER JOIN `Order` O on OP.orderId = O.orderId;

-- 3.4 Complex Join 2 (having more than 1 friend)

SELECT P1.*, COUNT(*) AS friendCount
FROM Person P1
         INNER JOIN Person_Person PP on P1.personId = PP.personId1
-- INNER JOIN Person P2 on PP.personId2 = P2.personId
GROUP BY P1.personId
HAVING COUNT(*) > 1;

-- 4. Unlimited Traversal (WITH RECURSIVE)

-- Find all direct and indirect relationships between people

WITH RECURSIVE PersonRelationships AS (SELECT personId1 AS sourcePersonId,
                                              personId2 AS relatedPersonId,
                                              1         AS depth
                                       FROM Person_Person
                                       UNION
                                       SELECT pr.sourcePersonId,
                                              pp.personId2 AS relatedPersonId,
                                              pr.depth + 1 AS depth
                                       FROM PersonRelationships pr
                                                JOIN Person_Person pp ON pr.relatedPersonId = pp.personId1
                                       WHERE pr.depth < 3 -- Limiting recursion depth to 3 for illustration
)
SELECT *
FROM PersonRelationships
ORDER BY sourcePersonId, depth, relatedPersonId;

-- Find the hierarchical structure of persons based on relationships using WITH RECURSIVE

-- Find the shortest path between two persons using WITH RECURSIVE

WITH RECURSIVE PersonPath AS (SELECT personId1 AS sourcePersonId,
                                     personId2 AS targetPersonId,
                                     personId1 AS currentPersonId,
                                     1         AS depth
                              FROM Person_Person
                              WHERE personId1 = 1  -- Specify the source person ID
                                AND personId2 = 10 -- Specify the target person ID
                              UNION
                              SELECT pp.sourcePersonId,
                                     pp.targetPersonId,
                                     pp.currentPersonId,
                                     pp.depth + 1 AS depth
                              FROM PersonPath pp
                                       JOIN Person_Person pp2 ON pp.currentPersonId = pp2.personId1
                              WHERE pp.currentPersonId <> pp.targetPersonId)
SELECT *
FROM PersonPath
ORDER BY sourcePersonId, depth, targetPersonId;


-- 5. Optional Traversal

-- 5.1 LEFT OUTER JOIN

-- Get a list of all people and their friend count (0 if they have no friends)
SELECT P1.personId,
       P1.firstName,
       P1.lastName,
#        CASE WHEN P2.personId IS NOT NULL THEN COUNT(*) ELSE 0 END
#            AS friendCount -- doesnt work in MySQL
       COUNT(*) AS friendCount -- must be fixed
FROM Person P1
         LEFT OUTER JOIN Person_Person PP on P1.personId = PP.personId1
         LEFT OUTER JOIN Person P2 on PP.personId2 = P2.personId
GROUP BY P1.personId, P1.firstName, P1.lastName;

-- 6. UNION

-- Get a list of contacts (email and phone) for both vendors and customers
-- Vendor contacts
SELECT 'Vendor'        AS entityType,
       Vendor.vendorId AS entityId,
       Vendor.name     AS entityName,
       Type.value      AS contactType,
       Vendor_Contacts.value
FROM Vendor
         JOIN Vendor_Contacts ON Vendor.vendorId = Vendor_Contacts.vendorId
         JOIN Type ON Vendor_Contacts.typeId = Type.typeId
UNION
-- Customer contacts
SELECT 'Order'                                    AS entityType,
       Customer.customerId                        AS entityId,
       Person.firstName || ' ' || Person.lastName AS entityName,
       Type.value                                 AS contactType,
       Order_Contacts.value
FROM Customer
         JOIN `Order` ON Customer.customerId = `Order`.customerId
         JOIN Order_Contacts ON `Order`.orderId = Order_Contacts.orderId
         JOIN Person ON Customer.personId = Person.personId
         JOIN Type ON Order_Contacts.typeId = Type.typeId
ORDER BY entityId, contactType;

-- 7. Intersection

-- Find common tags between posts and persons

-- Tags associated with posts
SELECT Tag.tagId AS tagId, Tag.value AS commonTag
FROM Post_Tags
         JOIN Tag ON Post_Tags.tagId = Tag.tagId
INTERSECT
-- Tags associated with persons
SELECT Tag.tagId AS tagId, Tag.value AS commonTag
FROM Person_Tags
         JOIN Tag ON Person_Tags.tagId = Tag.tagId
ORDER BY tagId;

-- In this query, we're using INTERSECT to find common tags between posts and persons.
-- The result includes the tag ID and value that are shared between the two tables.
-- The ORDER BY clause is used to sort the results by tag ID for better presentation.

-- 8. Difference

-- Find people who have not made any orders

-- All people
SELECT personId, firstName, lastName
FROM Person
WHERE personId NOT IN ( -- EXCEPT is not supported in MySQL, it is available in >8.0 though ????
-- People who have made orders
    SELECT Person.personId
    FROM Person
             JOIN Customer ON Person.personId = Customer.personId
             JOIN `Order` ON Customer.customerId = `Order`.customerId);


-- 9. Sorting

-- 9.1 Non-Indexed Columns

SELECT *
FROM Product
ORDER BY brand;

-- 9.2 Indexed Columns

SELECT *
FROM Product
ORDER BY productId;


-- 10. Distinct

-- Find unique combinations of product brands and the countries of the vendors selling those products

SELECT DISTINCT Product.brand, Vendor.country
FROM Product
         JOIN Vendor_Products ON Product.productId = Vendor_Products.productId
         JOIN Vendor ON Vendor_Products.vendorId = Vendor.vendorId
ORDER BY Product.brand, Vendor.country;

-- 11. MapReduce

-- Find the number of orders per customer

SELECT Customer.customerId, COUNT(*) AS orderCount
FROM Customer
         JOIN `Order` ON Customer.customerId = `Order`.customerId
GROUP BY Customer.customerId;