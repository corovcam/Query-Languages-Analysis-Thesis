DROP TABLE IF EXISTS Person_Tags;
DROP TABLE IF EXISTS Post_Tags;
DROP TABLE IF EXISTS Tag;
DROP TABLE IF EXISTS Post;
DROP TABLE IF EXISTS Order_Products;
DROP TABLE IF EXISTS Order_Contacts;
DROP TABLE IF EXISTS `Order`;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Person_Person;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Vendor_Contacts;
DROP TABLE IF EXISTS Industry;
DROP TABLE IF EXISTS Type;
DROP TABLE IF EXISTS Vendor_Products;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Vendor;

CREATE TABLE Vendor
(
    vendorId INTEGER PRIMARY KEY,
    -- vendorUuid BINARY(16) UNIQUE, -- How to specify UUID? to make references work
    name     TEXT,
    country  TEXT
);

CREATE TABLE Product
(
    productId INTEGER PRIMARY KEY,
    asin      TEXT NOT NULL,
    title     TEXT NOT NULL,
    price     REAL,
    brand     TEXT,
    imageUrl  TEXT
);

CREATE TABLE Vendor_Products
(
    vendorId  INTEGER NOT NULL,
    productId INTEGER NOT NULL,
    PRIMARY KEY (vendorId, productId),
    FOREIGN KEY (vendorId) REFERENCES Vendor (vendorId),
    FOREIGN KEY (productId) REFERENCES Product (productId)
);

CREATE TABLE Type
(
    typeId INTEGER PRIMARY KEY,
    value  TEXT
);

CREATE TABLE Industry
(
    vendorId INTEGER,
    typeId   INTEGER,
    PRIMARY KEY (vendorId, typeId),
    FOREIGN KEY (vendorId) REFERENCES Vendor (vendorId),
    FOREIGN KEY (typeId) REFERENCES Type (typeId)
);

CREATE TABLE Vendor_Contacts
(
    vendorId INTEGER,
    typeId   INTEGER,
    value    VARCHAR(255), -- type TEXT does not work as part of a composite key. How to make it equal to SQLite TEXT?
    PRIMARY KEY (vendorId, typeId, value),
    FOREIGN KEY (vendorId) REFERENCES Vendor (vendorId),
    FOREIGN KEY (typeId) REFERENCES Type (typeId)
);

CREATE TABLE Person
(
    personId   INTEGER PRIMARY KEY,
    firstName  TEXT,
    lastName   TEXT,
    gender     TEXT,
    birthday   DATETIME,
    street     TEXT,
    city       TEXT,
    postalCode TEXT,
    country    TEXT
);

CREATE TABLE Person_Person
(
    personId1 INTEGER,
    personId2 INTEGER,
    PRIMARY KEY (personId1, personId2),
    FOREIGN KEY (personId1) REFERENCES Person (personId),
    FOREIGN KEY (personId2) REFERENCES Person (personId)
);

CREATE TABLE Customer
(
    customerId INTEGER PRIMARY KEY,
    personId   INTEGER,
    FOREIGN KEY (personId) REFERENCES Person (personId)
);

CREATE TABLE `Order`
(
    orderId    INTEGER PRIMARY KEY,
    -- orderUuid  INTEGER,
    customerId INTEGER,
    FOREIGN KEY (customerId) REFERENCES Customer (customerId)
);

CREATE TABLE Order_Contacts
(
    orderId INTEGER,
    typeId  INTEGER,
    value   VARCHAR(255),
    PRIMARY KEY (orderId, typeId, value),
    FOREIGN KEY (orderId) REFERENCES `Order` (orderId),
    FOREIGN KEY (typeId) REFERENCES Type (typeId)
);

CREATE TABLE Order_Products
(
    orderId   INTEGER,
    productId INTEGER,
    quantity  INTEGER,
    PRIMARY KEY (orderId, productId),
    FOREIGN KEY (orderId) REFERENCES `Order` (orderId),
    FOREIGN KEY (productId) REFERENCES Product (productId)
);

CREATE TABLE Post
(
    postId       INTEGER PRIMARY KEY,
    personId     INTEGER,
    imageFile    TEXT,
    creationDate DATETIME,
    locationIP   TEXT,
    browserUsed  TEXT,
    language     TEXT,
    content      TEXT,
    length       INTEGER,
    FOREIGN KEY (personId) REFERENCES Person (personId)
);

CREATE TABLE Tag
(
    tagId INTEGER PRIMARY KEY,
    value TEXT
);

CREATE TABLE Post_Tags
(
    postId INTEGER,
    tagId  INTEGER,
    PRIMARY KEY (postId, tagId),
    FOREIGN KEY (postId) REFERENCES Post (postId),
    FOREIGN KEY (tagId) REFERENCES Tag (tagId)
);

CREATE TABLE Person_Tags
(
    personId INTEGER,
    tagId    INTEGER,
    PRIMARY KEY (personId, tagId),
    FOREIGN KEY (personId) REFERENCES Person (personId),
    FOREIGN KEY (tagId) REFERENCES Tag (tagId)
);