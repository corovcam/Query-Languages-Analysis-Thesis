DROP KEYSPACE IF EXISTS ecommerce;

CREATE KEYSPACE ecommerce
            WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE ecommerce;

CREATE TABLE Vendor
(
    vendorId   BIGINT PRIMARY KEY,
    -- vendorUuid UUID,
    name       TEXT,
    country    TEXT
) WITH COMMENT = 'Vendor information';

CREATE TABLE Product
(
    productId BIGINT PRIMARY KEY,
    asin      TEXT,
    title     TEXT,
    price     DOUBLE,
    brand     TEXT,
    imageUrl  TEXT
) WITH COMMENT = 'Product information';

CREATE TABLE ProductsByVendor
(
    vendorId  BIGINT,
    productId BIGINT,
//  Should we store the product information here?
/*    asin      TEXT,
    title     TEXT,
    price     DOUBLE,
    brand     TEXT,
    imageUrl  TEXT,*/
    PRIMARY KEY ((vendorId), productId)
) WITH COMMENT = 'Products by vendor';

/*CREATE TABLE Type
(
    typeId BIGINT PRIMARY KEY,
    value  TEXT
);*/

CREATE TABLE IndustryTypesByVendor
(
    vendorId BIGINT,
    typeId  BIGINT,
    value  TEXT,
    PRIMARY KEY ((vendorId), typeId),
);

