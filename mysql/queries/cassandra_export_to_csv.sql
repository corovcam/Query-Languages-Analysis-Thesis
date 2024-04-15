SET SESSION MAX_EXECUTION_TIME = 0; -- Disable the timeout for the session

-- Query 1.1, 1.3 : Select all products from a specific vendor
SELECT *
INTO OUTFILE '/mysql/exports/vendor.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Vendor;

-- Query 1.2: Select people born between 1980-01-01 and 1990-12-31 (without index)
-- Query 3.4: Find all people having more than 1 friend
-- Query 5.1: Get a list of all people and their friend count (0 if they have no friends)
SELECT P1.personId,
       P1.firstName,
       P1.lastName,
       P1.gender,
       DATE(P1.birthday),
       P1.street,
       P1.city,
       P1.postalCode,
       P1.country,
       COUNT(P2.personId) AS friendCount
INTO OUTFILE '/mysql/exports/person.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Person P1
         LEFT OUTER JOIN Person_Person PP on P1.personId = PP.personId1
         LEFT OUTER JOIN Person P2 on PP.personId2 = P2.personId
GROUP BY P1.personId;

-- Query 1.4 : Select people born between 1980-01-01 and 1990-12-31 (with index)
SELECT personId,
       firstName,
       lastName,
       gender,
       DATE(birthday),
       street,
       city,
       postalCode,
       country
INTO OUTFILE '/mysql/exports/person_by_birthday_indexed.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Person;

-- Query 2.1, 2.2 : GROUP BY brand queries
-- Query 9.1, 9.2: Sort by indexed/non-indexed column
SELECT *
INTO OUTFILE '/mysql/exports/product.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Product;

-- Query 3.1.: Return all Orders and Vendors sharing the same Contact typeId
-- This one was intentionally left out as it would require a self-join on the Order_Contacts table which would result in a large Cartesian product
-- The file takes more than 9GB of disk space during 4k experiments
-- SELECT OC.typeId,
--        OC.orderId,
--        OC.value,
--        VC.vendorId,
--        VC.value
-- INTO OUTFILE '/mysql/exports/vendor_contacts_by_order_contact.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
-- FROM Order_Contacts OC
--          INNER JOIN Vendor_Contacts VC on VC.typeId = OC.typeId;

-- Query 3.2.: Return all Products and the orderIds, quantities of the orders they were ordered in
SELECT P.*,
       orderId,
       quantity
INTO OUTFILE '/mysql/exports/orders_by_product.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Product P
         INNER JOIN Order_Products OP on P.productId = OP.productId;

-- Query 3.3.: Complex query to return Order details
SELECT o.orderId,
       o.customerId,
       p.personId,
       p.firstName,
       p.lastName,
       p.gender,
       DATE(p.birthday),
       p.street,
       p.city,
       p.postalCode,
       p.country,
       pr.productId,
       asin,
       title,
       price,
       brand,
       imageUrl,
       quantity,
       v.vendorId,
       v.name,
       v.country
INTO OUTFILE '/mysql/exports/order.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM `Order` o
         JOIN Customer c ON o.customerId = c.customerId
         JOIN Person p ON c.personId = p.personId
         JOIN Order_Products op ON o.orderId = op.orderId
         JOIN Product pr ON op.productId = pr.productId
         JOIN Vendor_Products vp ON pr.productId = vp.productId
         JOIN Vendor v ON vp.vendorId = v.vendorId;

-- Query 6: Get a list of contacts (email and phone) for both vendors and customers
SELECT *
INTO OUTFILE '/mysql/exports/contact.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM (SELECT 'Vendor'        AS entityType,
             Vendor.vendorId AS entityId,
             Vendor.name     AS entityName,
             Type.value      AS contactType,
             Vendor_Contacts.value
      FROM Vendor
               JOIN Vendor_Contacts ON Vendor.vendorId = Vendor_Contacts.vendorId
               JOIN Type ON Vendor_Contacts.typeId = Type.typeId
      UNION
      SELECT 'Order'                                        AS entityType,
             Customer.customerId                            AS entityId,
             CONCAT(Person.firstName, ' ', Person.lastName) AS entityName,
             Type.value                                     AS contactType,
             Order_Contacts.value
      FROM Customer
               JOIN `Order` ON Customer.customerId = `Order`.customerId
               JOIN Order_Contacts ON `Order`.orderId = Order_Contacts.orderId
               JOIN Person ON Customer.personId = Person.personId
               JOIN Type ON Order_Contacts.typeId = Type.typeId
      ORDER BY entityId, contactType) Contacts;

-- Query 7: Find common tags between posts and persons
SET SESSION group_concat_max_len = 1000000000; -- Equivalent to 1GB as the max_allowed_packet is set to 1GB
SELECT Tag.tagId,
       value,
       CONCAT('[', IF(GROUP_CONCAT(DISTINCT personId) IS NOT NULL, CONCAT_WS(',', -1, GROUP_CONCAT(DISTINCT personId)), ''), ']') AS interestedPeople,
       CONCAT('[', IF(GROUP_CONCAT(DISTINCT postId) IS NOT NULL, CONCAT_WS(',', -1, GROUP_CONCAT(DISTINCT postId)), ''), ']') AS postsTagged
INTO OUTFILE '/mysql/exports/tag.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Tag
         LEFT OUTER JOIN Person_Tags PeT ON PeT.tagId = Tag.tagId
         LEFT OUTER JOIN Post_Tags PoT ON PoT.tagId = Tag.tagId
GROUP BY tagId;

-- Query 8: Find people who have not made any orders
SELECT Person.personId,
       firstName,
       lastName,
       CONCAT('[', COALESCE(GROUP_CONCAT(DISTINCT orderId), -1), ']') AS ordersCreated
INTO OUTFILE '/mysql/exports/orders_by_person.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Person
         LEFT OUTER JOIN Customer ON Person.personId = Customer.personId
         LEFT OUTER JOIN `Order` ON Customer.customerId = `Order`.customerId
GROUP BY Person.personId;

-- Query 10: Find unique combinations of product brands and the countries of the vendors selling those products
SELECT DISTINCT Product.brand, Vendor.country
INTO OUTFILE '/mysql/exports/vendor_countries_by_product_brand.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Product
         JOIN Vendor_Products ON Product.productId = Vendor_Products.productId
         JOIN Vendor ON Vendor_Products.vendorId = Vendor.vendorId
ORDER BY Product.brand, Vendor.country;

-- Query 11: Find the number of orders per customer (only those who have made at least 1 order)
SELECT Customer.customerId, orderId
INTO OUTFILE '/mysql/exports/orders_by_customer.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY '\n'
FROM Customer
         JOIN `Order` ON Customer.customerId = `Order`.customerId;
