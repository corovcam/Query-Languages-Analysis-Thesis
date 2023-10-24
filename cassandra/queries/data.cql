USE eshop;

BEGIN
    BATCH
    INSERT INTO Vendor (vendorId, vendorUuid, name, country) VALUES (1, uuid(), 'Amazon', 'USA');
    INSERT INTO Vendor (vendorId, vendorUuid, name, country) VALUES (2, uuid(), 'Walmart', 'USA');
    INSERT INTO Vendor (vendorId, vendorUuid, name, country) VALUES (3, uuid(), 'Target', 'USA');

    INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
    VALUES (1, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple',
            'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');
    INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
    VALUES (2, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple',
            'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');
    INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
    VALUES (3, 'B07H65KP63', 'Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)', 699.99, 'Apple',
            'https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg');

    INSERT INTO ProductsByVendor (vendorId, productId) VALUES (1, 1);
    INSERT INTO ProductsByVendor (vendorId, productId) VALUES (2, 2);
    INSERT INTO ProductsByVendor (vendorId, productId) VALUES (3, 3);
    APPLY BATCH;
