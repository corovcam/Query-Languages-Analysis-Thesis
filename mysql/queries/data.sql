/*INSERT INTO Vendor (vendorId, name, country)
VALUES (1, 'Amazon', 'USA'),
       (2, 'Walmart', 'USA'),
       (3, 'Target', 'USA');

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
       (3, 3);*/

-- Sample data for the Type table
INSERT INTO Type (typeId, value)
VALUES (1, 'Email'),
       (2, 'Phone'),
       (3, 'Address'),
       -- Should I split Type into ContactType and IndustryType?
       (4, 'Automotive'),
       (5, 'Electronics');

-- Sample data for the Vendor table
INSERT INTO Vendor (vendorId, name, country)
VALUES (1, 'Vendor A', 'USA'),
       (2, 'Vendor B', 'Canada');

-- Sample data for the Product table
INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
VALUES (1, 'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg'),
       (2, 'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg');

-- Sample data for the Vendor_Products table (associating vendors with products)
INSERT INTO Vendor_Products (vendorId, productId)
VALUES (1, 1),
       (1, 2),
       (2, 2);

-- Sample data for the Industry table
INSERT INTO Industry (vendorId, typeId)
VALUES (1, 4),
       (1, 5),
       (2, 5);

-- Sample data for the Vendor_Contacts table
INSERT INTO Vendor_Contacts (vendorId, typeId, value)
VALUES (1, 1, 'vendorA@example.com'),
       (1, 2, '123-456-7890'),
       (2, 2, '987-654-3210');

-- Sample data for the Person table
INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
VALUES (1, 'John', 'Doe', 'Male', '1980-05-15', '123 Main St', 'New York', '10001', 'USA'),
       (2, 'Jane', 'Smith', 'Female', '1990-08-25', '456 Elm St', 'Toronto', 'M5V 1A1', 'Canada');

-- Sample data for the Customer table
INSERT INTO Customer (customerId, personId)
VALUES (1, 1),
       (2, 2);

-- Sample data for the Order table
INSERT INTO `Order` (orderId, customerId)
VALUES (1, 1),
       (2, 2);

-- Sample data for the Order_Contacts table
INSERT INTO Order_Contacts (orderId, typeId, value)
VALUES (1, 1, 'john@example.com'),
       (1, 2, '111-222-3333'),
       (2, 1, 'jane@example.com'),
       (2, 2, '444-555-6666');

-- Sample data for the Order_Products table
INSERT INTO Order_Products (orderId, productId, quantity)
VALUES (1, 1, 2),
       (2, 2, 3);

-- Sample data for the Person_Person table (for relationships)
INSERT INTO Person_Person (personId1, personId2)
VALUES (1, 2); -- should I include also (2, 1) to make it bidirectional? Or is it redundant?

-- Sample data for the Post table
INSERT INTO Post (postId, personId, imageFile, creationDate, locationIP, browserUsed, language, content, length)
VALUES (1, 1, 'post1.jpg', '2023-10-30 12:00:00', '192.168.1.1', 'Chrome', 'English', 'This is a sample post.', 100),
       (2, 2, 'post2.jpg', '2023-10-30 13:00:00', '192.168.1.2', 'Firefox', 'English', 'Another sample post.', 120);

-- Sample data for the Tag table
INSERT INTO Tag (tagId, value)
VALUES (1, 'Technology'),
       (2, 'Travel');

-- Sample data for the Post_Tags table (associating posts with tags)
INSERT INTO Post_Tags (postId, tagId)
VALUES (1, 1),
       (2, 2);

-- Sample data for the Person_Tags table (associating persons with tags)
INSERT INTO Person_Tags (personId, tagId)
VALUES (1, 2),
       (2, 1);
