/*
CREATE TABLE Vendor (
    vendorId INTEGER PRIMARY KEY,
    name TEXT,
    country TEXT
);

CREATE TABLE Product (
    productId INTEGER PRIMARY KEY,
    asin TEXT NOT NULL,
    title TEXT NOT NULL,
    price REAL,
    brand TEXT,
    imageUrl TEXT
);

CREATE TABLE Vendor_Products (
    vendorId INTEGER NOT NULL,
    productId INTEGER NOT NULL,
    PRIMARY KEY (vendorId, productId),
    FOREIGN KEY (vendorId) REFERENCES Vendor(vendorId),
    FOREIGN KEY (productId) REFERENCES Product(productId)
);
*/

-- Insert some random diffrent data into the tables above.
INSERT INTO Vendor (vendorId, name, country) 
VALUES (1, 'Amazon', 'USA'), (2, 'Walmart', 'USA'), (3, 'Target', 'USA');

INSERT INTO Product (productId, asin, title, price, brand, imageUrl) VALUES (1, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple', 'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');
INSERT INTO Product (productId, asin, title, price, brand, imageUrl) VALUES (2, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple', 'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');
INSERT INTO Product (productId, asin, title, price, brand, imageUrl) VALUES (3, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple', 'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');

INSERT INTO Vendor_Products (vendorId, productId) VALUES (1, 1), (2, 2), (3, 3);
