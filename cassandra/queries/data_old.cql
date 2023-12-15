USE ecommerce;

BEGIN
    BATCH
    INSERT INTO Vendor (vendorId, name, country) VALUES (1, 'Vendor A', 'USA');
    INSERT INTO Vendor (vendorId, name, country) VALUES (2, 'Vendor B', 'Canada');
    INSERT INTO Vendor (vendorId, name, country) VALUES (3, 'Target', 'USA');

    INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
    VALUES (1, 'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg');
    INSERT INTO Product (productId, asin, title, price, brand, imageUrl)
    VALUES (2, 'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg');

    INSERT INTO Products_By_Brand (productId, asin, title, price, brand, imageUrl)
    VALUES (1, 'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg');
    INSERT INTO Products_By_Brand (productId, asin, title, price, brand, imageUrl)
    VALUES (2, 'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg');

    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (1, 'John', 'Doe', 'Male', '1980-05-15', '123 Main St', 'New York', '10001', 'USA', 4);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (2, 'Jane', 'Smith', 'Female', '1990-08-25', '456 Elm St', 'Toronto', 'M5V 1A1', 'Canada', 0);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (3, 'Michael', 'Johnson', 'Male', '1983-03-10', '789 Oak St', 'London', 'EC1A 1BB', 'UK', 1);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (4, 'Sophia', 'Müller', 'Female', '1986-06-20', '101 Birch St', 'Berlin', '10115', 'Germany', 2);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (5, 'Alex', 'Dupont', 'Male', '1995-01-05', '456 Maple St', 'Paris', '75001', 'France', 0);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (6, 'Giulia', 'Rossi', 'Female', '1990-12-15', '789 Vine St', 'Rome', '00100', 'Italy', 4);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (7, 'Takashi', 'Yamamoto', 'Male', '1980-08-01', '123 Sakura St', 'Tokyo', '100-0001', 'Japan', 1);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (8, 'Mia', 'Johnson', 'Female', '1992-05-30', '456 Cherry St', 'Sydney', '2000', 'Australia', 0);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (9, 'Lucas', 'Silva', 'Male', '1985-11-18', '789 Kangaroo St', 'Melbourne', '3000', 'Australia', 1);
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount)
    VALUES (10, 'Isabella', 'Pereira', 'Female', '1991-04-25', '101 Copacabana St', 'Rio de Janeiro', '20000-000',
            'Brazil', 1);

    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (1, 'John', 'Doe', 'Male', '1980-05-15', '123 Main St', 'New York', '10001', 'USA');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (2, 'Jane', 'Smith', 'Female', '1990-08-25', '456 Elm St', 'Toronto', 'M5V 1A1', 'Canada');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (3, 'Michael', 'Johnson', 'Male', '1983-03-10', '789 Oak St', 'London', 'EC1A 1BB', 'UK');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (4, 'Sophia', 'Müller', 'Female', '1986-06-20', '101 Birch St', 'Berlin', '10115', 'Germany');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (5, 'Alex', 'Dupont', 'Male', '1995-01-05', '456 Maple St', 'Paris', '75001', 'France');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (6, 'Giulia', 'Rossi', 'Female', '1990-12-15', '789 Vine St', 'Rome', '00100', 'Italy');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (7, 'Takashi', 'Yamamoto', 'Male', '1980-08-01', '123 Sakura St', 'Tokyo', '100-0001', 'Japan');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (8, 'Mia', 'Johnson', 'Female', '1992-05-30', '456 Cherry St', 'Sydney', '2000', 'Australia');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (9, 'Lucas', 'Silva', 'Male', '1985-11-18', '789 Kangaroo St', 'Melbourne', '3000', 'Australia');
    INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode,
                                            country)
    VALUES (10, 'Isabella', 'Pereira', 'Female', '1991-04-25', '101 Copacabana St', 'Rio de Janeiro', '20000-000',
            'Brazil');

    insert into Vendor_Contacts_By_Order_Contact (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (1, 1, 'john@example.com', 1, 'vendorA@example.com');
    insert into Vendor_Contacts_By_Order_Contact (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (1, 2, 'jane@example.com', 1, 'vendorA@example.com');
    insert into Vendor_Contacts_By_Order_Contact (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (2, 1, '111-222-3333', 1, '123-456-7890');
    insert into Vendor_Contacts_By_Order_Contact (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (2, 2, '444-555-6666', 1, '123-456-7890');
    insert into Vendor_Contacts_By_Order_Contact (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (2, 1, '111-222-3333', 2, '987-654-3210');
    insert into Vendor_Contacts_By_Order_Contact (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (2, 2, '444-555-6666', 2, '987-654-3210');

    insert into Orders_By_Product (productId, asin, title, price, brand, imageUrl, orderId, quantity)
    values (1, 'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg', 1, 2);
    insert into Orders_By_Product (productId, asin, title, price, brand, imageUrl, orderId, quantity)
    values (1, 'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg', 2, 1);
    insert into Orders_By_Product (productId, asin, title, price, brand, imageUrl, orderId, quantity)
    values (2, 'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg', 1, 1);
    insert into Orders_By_Product (productId, asin, title, price, brand, imageUrl, orderId, quantity)
    values (2, 'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg', 2, 3);

    insert into "Order" (orderId, customerId, personId, firstName, lastName, gender, birthday, street, city, postalCode,
                         personCountry, productId, quantity, asin, title, price, brand, imageUrl, vendorId, vendorName,
                         vendorCountry)
    values (1, 1, 1, 'John', 'Doe', 'Male', '1980-05-15', '123 Main St', 'New York', '10001', 'USA', 2, 1,
            'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg', 1, 'Vendor A', 'USA');
    insert into "Order" (orderId, customerId, personId, firstName, lastName, gender, birthday, street, city, postalCode,
                         personCountry, productId, quantity, asin, title, price, brand, imageUrl, vendorId, vendorName,
                         vendorCountry)
    values (2, 2, 2, 'Jane', 'Smith', 'Female', '1990-08-25', '456 Elm St', 'Toronto', 'M5V 1A1', 'Canada', 2,
            3, 'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg', 1, 'Vendor A', 'USA');
    insert into "Order" (orderId, customerId, personId, firstName, lastName, gender, birthday, street, city, postalCode,
                         personCountry, productId, quantity, asin, title, price, brand, imageUrl, vendorId, vendorName,
                         vendorCountry)
    values (1, 1, 1, 'John', 'Doe', 'Male', '1980-05-15', '123 Main St', 'New York', '10001', 'USA', 1, 2,
            'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg', 1, 'Vendor A', 'USA');
    insert into "Order" (orderId, customerId, personId, firstName, lastName, gender, birthday, street, city, postalCode,
                         personCountry, productId, quantity, asin, title, price, brand, imageUrl, vendorId, vendorName,
                         vendorCountry)
    values (2, 2, 2, 'Jane', 'Smith', 'Female', '1990-08-25', '456 Elm St', 'Toronto', 'M5V 1A1', 'Canada', 1,
            1, 'ASIN123', 'Product 1', 19.99, 'Brand X', 'product1.jpg', 1, 'Vendor A', 'USA');
    insert into "Order" (orderId, customerId, personId, firstName, lastName, gender, birthday, street, city, postalCode,
                         personCountry, productId, quantity, asin, title, price, brand, imageUrl, vendorId, vendorName,
                         vendorCountry)
    values (1, 1, 1, 'John', 'Doe', 'Male', '1980-05-15', '123 Main St', 'New York', '10001', 'USA', 2, 1,
            'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg', 2, 'Vendor B', 'Canada');
    insert into "Order" (orderId, customerId, personId, firstName, lastName, gender, birthday, street, city, postalCode,
                         personCountry, productId, quantity, asin, title, price, brand, imageUrl, vendorId, vendorName,
                         vendorCountry)
    values (2, 2, 2, 'Jane', 'Smith', 'Female', '1990-08-25', '456 Elm St', 'Toronto', 'M5V 1A1', 'Canada', 2,
            3, 'ASIN456', 'Product 2', 29.99, 'Brand Y', 'product2.jpg', 2, 'Vendor B', 'Canada');

    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 2, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 3, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 4, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 5, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 4, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 5, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 10, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 1, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 5, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (1, 10, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (3, 4, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (3, 5, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (3, 10, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (3, 1, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (4, 5, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (4, 10, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (4, 1, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (4, 2, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (4, 3, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (4, 4, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (4, 5, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 7, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 8, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 9, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 10, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 1, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 8, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 10, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 1, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 2, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 3, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 4, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (6, 5, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (7, 8, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (9, 10, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (9, 1, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (9, 2, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (9, 3, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (9, 4, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (9, 5, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 1, 1);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 2, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 3, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 4, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 5, 2);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 4, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 5, 3);
    insert into Person_Relationships (sourcePersonId, relatedPersonId, depth) values (10, 10, 3);

    insert into Contact (entityType, entityId, entityName, contactType, contactValue)
    values ('Vendor', 1, 'Vendor A', 'Email', 'vendorA@example.com');
    insert into Contact (entityType, entityId, entityName, contactType, contactValue)
    values ('Order', 1, 'John Doe', 'Email', 'john@example.com');
    insert into Contact (entityType, entityId, entityName, contactType, contactValue)
    values ('Vendor', 1, 'Vendor A', 'Phone', '123-456-7890');
    insert into Contact (entityType, entityId, entityName, contactType, contactValue)
    values ('Order', 1, 'John Doe', 'Phone', '111-222-3333');
    insert into Contact (entityType, entityId, entityName, contactType, contactValue)
    values ('Order', 2, 'Jane Smith', 'Email', 'jane@example.com');
    insert into Contact (entityType, entityId, entityName, contactType, contactValue)
    values ('Vendor', 2, 'Vendor B', 'Phone', '987-654-3210');
    insert into Contact (entityType, entityId, entityName, contactType, contactValue)
    values ('Order', 2, 'Jane Smith', 'Phone', '444-555-6666');

    insert into Tag (tagId, value, interestedPeople, postsTagged) values (1, 'Technology', { -1, 2 }, { -1, 1, 2 });
    insert into Tag (tagId, value, interestedPeople, postsTagged) values (2, 'Travel', { -1, 1 }, { -1, 2 });
    insert into Tag (tagId, value, interestedPeople, postsTagged) values (3, 'Fashion', { -1, 4 }, { -1, 1 });
    insert into Tag (tagId, value, interestedPeople, postsTagged) values (4, 'Food', { -1, 3 }, { -1, 2 });
    insert into Tag (tagId, value, interestedPeople, postsTagged) values (5, 'Health', { -1, 6 }, { });
    insert into Tag (tagId, value, interestedPeople, postsTagged) values (6, 'Sports', { -1, 5 }, { });

    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated) values (1, 'John', 'Doe', { 1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated) values (2, 'Jane', 'Smith', { 2 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated)
    values (3, 'Michael', 'Johnson', { -1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated)
    values (4, 'Sophia', 'Müller', { -1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated) values (5, 'Alex', 'Dupont', { -1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated) values (6, 'Giulia', 'Rossi', { -1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated)
    values (7, 'Takashi', 'Yamamoto', { -1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated) values (8, 'Mia', 'Johnson', { -1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated) values (9, 'Lucas', 'Silva', { -1 });
    insert into Orders_By_Person (personId, firstName, lastName, ordersCreated)
    values (10, 'Isabella', 'Pereira', { -1 });

    insert into Vendor_Countries_By_Product_Brand (brand, country) values ('Brand X', 'USA');
    insert into Vendor_Countries_By_Product_Brand (brand, country) values ('Brand Y', 'Canada');
    insert into Vendor_Countries_By_Product_Brand (brand, country) values ('Brand Y', 'USA');

    insert into Orders_By_Customer (customerId, orderId) values (1, 1);
    insert into Orders_By_Customer (customerId, orderId) values (2, 2);

    APPLY BATCH;
