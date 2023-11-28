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

    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (1, 'John', 'Doe', 'Male', '1980-05-15', '123 Main St', 'New York', '10001', 'USA');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (2, 'Jane', 'Smith', 'Female', '1990-08-25', '456 Elm St', 'Toronto', 'M5V 1A1', 'Canada');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (3, 'Michael', 'Johnson', 'Male', '1983-03-10', '789 Oak St', 'London', 'EC1A 1BB', 'UK');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (4, 'Sophia', 'Müller', 'Female', '1986-06-20', '101 Birch St', 'Berlin', '10115', 'Germany');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (5, 'Alex', 'Dupont', 'Male', '1995-01-05', '456 Maple St', 'Paris', '75001', 'France');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (6, 'Giulia', 'Rossi', 'Female', '1990-12-15', '789 Vine St', 'Rome', '00100', 'Italy');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (7, 'Takashi', 'Yamamoto', 'Male', '1980-08-01', '123 Sakura St', 'Tokyo', '100-0001', 'Japan');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (8, 'Mia', 'Johnson', 'Female', '1992-05-30', '456 Cherry St', 'Sydney', '2000', 'Australia');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (9, 'Lucas', 'Silva', 'Male', '1985-11-18', '789 Kangaroo St', 'Melbourne', '3000', 'Australia');
    INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country)
    VALUES (10, 'Isabella', 'Pereira', 'Female', '1991-04-25', '101 Copacabana St', 'Rio de Janeiro', '20000-000',
            'Brazil');

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

    insert into Order_Vendor_Contacts_By_Contact_Type (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (1, 1, 'john@example.com', 1, 'vendorA@example.com');
    insert into Order_Vendor_Contacts_By_Contact_Type (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (1, 2, 'jane@example.com', 1, 'vendorA@example.com');
    insert into Order_Vendor_Contacts_By_Contact_Type (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (2, 1, '111-222-3333', 1, '123-456-7890');
    insert into Order_Vendor_Contacts_By_Contact_Type (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (2, 2, '444-555-6666', 1, '123-456-7890');
    insert into Order_Vendor_Contacts_By_Contact_Type (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
    values (2, 1, '111-222-3333', 2, '987-654-3210');
    insert into Order_Vendor_Contacts_By_Contact_Type (typeId, orderId, orderContactValue, vendorId, vendorContactValue)
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


    APPLY BATCH;
