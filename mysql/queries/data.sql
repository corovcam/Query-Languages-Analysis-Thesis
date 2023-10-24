INSERT INTO Vendor (vendorId, vendorUuid, name, country)
VALUES (1, UUID_TO_BIN(UUID()), 'Amazon', 'USA'),
       (2, UUID_TO_BIN(UUID()), 'Walmart', 'USA'),
       (3, UUID_TO_BIN(UUID()), 'Target', 'USA');

INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
VALUES (1, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple',
        'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');
INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
VALUES (2, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple',
        'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');
INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
VALUES (3, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple',
        'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');

INSERT INTO Vendor_Products (vendorId, productId)
VALUES (1, 1),
       (2, 2),
       (3, 3);
