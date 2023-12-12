DROP TABLE IF EXISTS Vendor;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Vendor_Products;
DROP TABLE IF EXISTS Industry;
DROP TABLE IF EXISTS Vendor_Contacts;
DROP TABLE IF EXISTS Type;
DROP TABLE IF EXISTS `Order`;
DROP TABLE IF EXISTS Order_Contacts;
DROP TABLE IF EXISTS Order_Products;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Person_Person;
DROP TABLE IF EXISTS Post;
DROP TABLE IF EXISTS Tag;
DROP TABLE IF EXISTS Post_Tags;
DROP TABLE IF EXISTS Person_Tags;

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
    vendorId  INTEGER NOT NULL REFERENCES Vendor (vendorId),
    productId INTEGER NOT NULL REFERENCES Product (productId),
    PRIMARY KEY (vendorId, productId)
) WITHOUT ROWID; -- composite primary key without rowid (to save space)

CREATE TABLE Industry
(
    vendorId INTEGER REFERENCES Vendor (vendorId),
    typeId   INTEGER REFERENCES Type (typeId),
    PRIMARY KEY (vendorId, typeId)
) WITHOUT ROWID;

CREATE TABLE Vendor_Contacts
(
    vendorId INTEGER REFERENCES Vendor (vendorId),
    typeId   INTEGER REFERENCES Type (typeId),
    value    TEXT, -- How to make it equal to MySQL VARCHAR?
    PRIMARY KEY (vendorId, typeId, value)
) WITHOUT ROWID;

CREATE TABLE Type
(
    typeId INTEGER PRIMARY KEY,
    value  TEXT
);

CREATE TABLE `Order`
(
    orderId    INTEGER PRIMARY KEY,
    -- orderUuid  INTEGER,
    customerId INTEGER REFERENCES Customer (customerId)
);

CREATE TABLE Order_Contacts
(
    orderId INTEGER REFERENCES `Order` (orderId),
    typeId  INTEGER REFERENCES Type (typeId),
    value   TEXT,
    PRIMARY KEY (orderId, typeId, value)
) WITHOUT ROWID;

CREATE TABLE Order_Products
(
    orderId   INTEGER REFERENCES `Order` (orderId),
    productId INTEGER REFERENCES Product (productId),
    quantity  INTEGER,
    PRIMARY KEY (orderId, productId)
) WITHOUT ROWID;

CREATE TABLE Customer
(
    customerId INTEGER PRIMARY KEY,
    personId   INTEGER REFERENCES Person (personId)
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
    personId1 INTEGER REFERENCES Person (personId),
    personId2 INTEGER REFERENCES Person (personId),
    PRIMARY KEY (personId1, personId2)
) WITHOUT ROWID;

-- Not used in Queries
CREATE TABLE Post
(
    postId       INTEGER PRIMARY KEY,
    personId     INTEGER REFERENCES Person (personId),
    imageFile    TEXT,
    creationDate DATETIME,
    locationIP   TEXT,
    browserUsed  TEXT,
    language     TEXT,
    content      TEXT,
    length       INTEGER
);

CREATE TABLE Tag
(
    tagId INTEGER PRIMARY KEY,
    value TEXT
);

CREATE TABLE Post_Tags
(
    postId INTEGER REFERENCES Post (postId),
    tagId  INTEGER REFERENCES Tag (tagId),
    PRIMARY KEY (postId, tagId)
) WITHOUT ROWID;

CREATE TABLE Person_Tags
(
    personId INTEGER REFERENCES Person (personId),
    tagId    INTEGER REFERENCES Tag (tagId),
    PRIMARY KEY (personId, tagId)
) WITHOUT ROWID;