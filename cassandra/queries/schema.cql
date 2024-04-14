DROP KEYSPACE IF EXISTS ecommerce;

CREATE KEYSPACE ecommerce
            WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE ecommerce;

-- Query 1.1, 1.3 : Select all products from a specific vendor
CREATE TABLE Vendor
(
    vendorId BIGINT PRIMARY KEY,
    name     TEXT,
    country  TEXT
) WITH COMMENT = 'Vendor information'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 1.2: Select people born between 1980-01-01 and 1990-12-31 (without index)
-- Query 3.4: Find all people having more than 1 friend
-- Query 5.1: Get a list of all people and their friend count (0 if they have no friends)
CREATE TABLE Person
(
    personId    BIGINT,
    firstName   TEXT,
    lastName    TEXT,
    gender      TEXT,
    birthday    DATE,
    street      TEXT,
    city        TEXT,
    postalCode  TEXT,
    country     TEXT,
    friendCount BIGINT,
    PRIMARY KEY ((personId), friendCount)
) WITH COMMENT = 'Person information'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 1.4 : Select people born between 1980-01-01 and 1990-12-31 (with index)
-- https://dba.stackexchange.com/questions/313576/how-to-efficiently-run-range-based-queries-in-cassandra
-- Can't use a range query on a secondary index, so we need to use clustering column for birthday
CREATE TABLE Person_By_Birthday_Indexed
(
    personId   BIGINT,
    firstName  TEXT,
    lastName   TEXT,
    gender     TEXT,
    birthday   DATE,
    street     TEXT,
    city       TEXT,
    postalCode TEXT,
    country    TEXT,
    PRIMARY KEY ((personId), birthday)
) WITH COMMENT = 'People by birthday - clustering index on birthday'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 2.1, 2.2 : GROUP BY brand queries
CREATE TABLE Products_By_Brand
(
    productId BIGINT,
    asin      TEXT,
    title     TEXT,
    price     DOUBLE,
    brand     TEXT,
    imageUrl  TEXT,
    PRIMARY KEY ((brand), productId)
) WITH COMMENT = 'Products by brand'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 3.1.: Return all Orders and Vendors sharing the same Contact typeId
CREATE TABLE Vendor_Contacts_By_Order_Contact
(
    typeId             BIGINT,
    orderId            BIGINT,
    orderContactValue  TEXT,
    vendorId           BIGINT,
    vendorContactValue TEXT,
    PRIMARY KEY ((typeId, orderId, orderContactValue), vendorId, vendorContactValue)
) WITH COMMENT = 'Order and Vendor contacts by Order Contact type'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 3.2.: Return all Products and the orderIds, quantities of the orders they were ordered in
// TODO: Maybe embed the order information into the Product table?
CREATE TABLE Orders_By_Product
(
    productId BIGINT,
    asin      TEXT,
    title     TEXT,
    price     DOUBLE,
    brand     TEXT,
    imageUrl  TEXT,
    orderId   BIGINT,
    quantity  BIGINT, -- To be consistent with all other DBs (64-bit integer in most of them)
    PRIMARY KEY ((productId), orderId)
) WITH COMMENT = 'Orders by product'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 3.3.: Complex query to return Order details
CREATE TABLE "Order"
(
    orderId       BIGINT,
    -- Customer
    customerId    BIGINT,
    -- Person
    personId      BIGINT,
    firstName     TEXT,
    lastName      TEXT,
    gender        TEXT,
    birthday      DATE,
    street        TEXT,
    city          TEXT,
    postalCode    TEXT,
    personCountry TEXT,
    -- Product(s)
    productId     BIGINT,
    asin          TEXT,
    title         TEXT,
    price         DOUBLE,
    brand         TEXT,
    imageUrl      TEXT,
    -- Product(s) quantity
    quantity      BIGINT,
    -- Vendor
    vendorId      BIGINT,
    vendorName    TEXT,
    vendorCountry TEXT,
    PRIMARY KEY ((orderId, customerId, productId, vendorId))
) WITH COMMENT = 'Order information'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 4.1.: Find all direct and indirect relationships between people (friends of friends up to depth of 3)
-- Note that relationship between a person and themselves may exist (if cycle exists)
-- CREATE TABLE Person_Relationships
-- (
--     sourcePersonId  BIGINT,
--     relatedPersonId BIGINT,
--     depth           INT, -- Depth of the relationship (1 = direct, 2 = friend of friend, 3 = friend of friend of friend)
--     PRIMARY KEY ((sourcePersonId), depth, relatedPersonId)
-- ) WITH COMMENT = 'Person relationships (friends of friends up to depth of 3)'
--    AND caching = {
--             'keys' : 'NONE',
--             'rows_per_partition' : 'NONE'
--             };
-- explain in discussion how it can be done
-- why is inneficient in application layer
-- using only query language constructs, its inneficient (exponential complexity)

-- Query 6: Get a list of contacts (email and phone) for both vendors and customers
CREATE TABLE Contact
(
    entityType   TEXT,
    entityId     BIGINT,
    entityName   TEXT,
    contactType  TEXT,
    contactValue TEXT,
    PRIMARY KEY ((entityId, contactType, contactValue))
) WITH COMMENT = 'Contact information'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 7: Find common tags between posts and persons
CREATE TABLE Tag
(
    tagId            BIGINT,
    value            TEXT,
    interestedPeople FROZEN<SET<BIGINT>>,
    postsTagged      FROZEN<SET<BIGINT>>,
    PRIMARY KEY ((tagId), interestedPeople, postsTagged)
) WITH COMMENT = 'Tag information'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 8: Find people who have not made any orders
-- We can just find a record with a dummy value (-1) that represents "null" (no orders)
-- (Cassandra doesn't support filtering by null values)
CREATE TABLE Orders_By_Person
(
    personId      BIGINT,
    firstName     TEXT,
    lastName      TEXT,
    ordersCreated FROZEN<SET<BIGINT>>,
    PRIMARY KEY ((personId), ordersCreated)
) WITH COMMENT = 'Orders by person'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 9.1, 9.2: Sort by indexed/non-indexed column
CREATE TABLE Product
(
    productId BIGINT PRIMARY KEY,
    asin      TEXT,
    title     TEXT,
    price     DOUBLE,
    brand     TEXT,
    imageUrl  TEXT,
) WITH COMMENT = 'Product information'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 10: Find unique combinations of product brands and the countries of the vendors selling those products
CREATE TABLE Vendor_Countries_By_Product_Brand
(
    brand   TEXT,
    country TEXT,
    PRIMARY KEY ((brand), country)
) WITH COMMENT = 'Vendor countries by product brand'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };

-- Query 11: Find the number of orders per customer (only those who have made at least 1 order)
CREATE TABLE Orders_By_Customer
(
    customerId BIGINT,
    orderId    BIGINT,
    PRIMARY KEY ((customerId), orderId)
) WITH COMMENT = 'Orders by customer'
   AND caching = {
            'keys' : 'NONE',
            'rows_per_partition' : 'NONE'
            };
