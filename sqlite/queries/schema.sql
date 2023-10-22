DROP TABLE IF EXISTS Vendor;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Vendor_Products;
DROP TABLE IF EXISTS Industry;
DROP TABLE IF EXISTS Contact;
DROP TABLE IF EXISTS Type;
DROP TABLE IF EXISTS "Order";
DROP TABLE IF EXISTS Order_Products;

CREATE TABLE Vendor
(
    vendorId INTEGER PRIMARY KEY,
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