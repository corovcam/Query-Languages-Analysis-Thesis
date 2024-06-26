const fs = require('fs');
const { faker } = require('@faker-js/faker');

// Using same seed and ref date for all faker functions to ensure consistency and reproducibility
faker.seed(123);
faker.setDefaultRefDate('2000-01-01T00:00:00.000Z');

// Utility functions

const STRING_MAX_ALLOWED_LENGTH = 65535;  // 64KB

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function chooseContactValue(type) {
    switch (type.toLowerCase()) {
        case "email":
            return faker.internet.email();
        case "phone":
            return faker.phone.number();
        case "address":
            return `${faker.location.streetAddress({ useFullAddress: true }).replace(/'/g, "''")}, ${faker.location.city().replace(/'/g, "''")}, ${faker.location.country().replace(/'/g, "''")}`;
        default:
            return null;
    }
}

function checkStringLengthAndAppendToFile(data, fileName) {
    if (data.length >= STRING_MAX_ALLOWED_LENGTH) {
        fs.appendFileSync(fileName, data);
        return '';
    }
    return data;
}

// SQLite, MySQL, Cassandra dummy data generator

/**
 * @typedef {import("./types").Vendor} Vendor
 * @typedef {import("./types").Product} Product
 * @typedef {import("./types").Person} Person
 * @typedef {import("./types").Order} Order
 * @typedef {import("./types").Tag} Tag
 * @typedef {import("./types").Type} Type
 */

// Global entity objects
/** @type {Vendor[]} */
let vendorObjects = [];
/** @type {Product[]} */
let productObjects = [];
/** @type {Person[]} */
let peopleObjects = [];
/** @type {Order[]} */
let orderObjects = [];
/** @type {Tag[]} */
let tagObjects = [];

function getTypeMapping(industryCount = 10, contactTypes = ["Email", "Phone", "Address"]) {
    const industryTypes = faker.helpers.uniqueArray(() => faker.commerce.department().replace(/'/g, "''"), industryCount);
    let typeMapping = contactTypes.map((type, index) => ({ typeId: index + 1, typeFor: "contact", value: type }));
    typeMapping.push(...industryTypes.map((type, index) => ({ typeId: index + 1 + contactTypes.length, typeFor: "industry", value: type })));
    return typeMapping;
}

function generateTypes(typeMapping) {
    let types = [];
    typeMapping.forEach(type => {
        types.push(`(${type.typeId}, '${type.value}')`);
    });
    return `INSERT INTO Type (typeId, value) VALUES ${types.join(", \n")};\n`;
}

function generateVendorsProducts(vendorCount = 100, productCount = 1000, typeMapping = getTypeMapping()) {
    let vendors = [];
    let products = [];
    let vendorProducts = [];
    let vendorIndustries = [];
    let vendorContacts = [];

    let brandVendorsByProductId = {};
    let countriesByBrand = {};

    const industryTypes = typeMapping.filter(type => type.typeFor === "industry")
    let productsAssigned = 0;
    for (let i = 0; i < vendorCount; i++) {
        const vendorId = i + 1;
        const vendorName = faker.company.name().replace(/'/g, "''");
        const vendorCountry = faker.location.country().replace(/'/g, "''");

        vendorObjects.push({ vendorId, name: vendorName, country: vendorCountry, contacts: [] });
        vendors.push(`(${vendorId}, '${vendorName}', '${vendorCountry}')`);

        // Assign Products to Vendor
        let productsPerVendor = faker.number.int({ max: 20 });
        const productsAssignable = productCount - productsAssigned;
        if (productsPerVendor > productsAssignable) {
            productsPerVendor = productsAssignable;
        }
        for (let j = productsAssigned; j < productsAssigned + productsPerVendor; j++) {
            const productId = j + 1;
            const asin = faker.string.nanoid(10).toUpperCase();
            const title = faker.commerce.productName().replace(/'/g, "''");
            const price = faker.commerce.price();
            const brand = faker.helpers.weightedArrayElement([
                { weight: 0.8, value: vendorName },
                { weight: 0.2, value: capitalizeFirstLetter(faker.lorem.word()) }
            ]);
            const imageUrl = faker.image.url();

            products.push(`(${productId}, '${asin}', '${title}', ${price}, '${brand}', '${imageUrl}')`);
            vendorProducts.push(`(${vendorId}, ${productId})`);

            productObjects.push({
                productId, asin, title, price, brand, imageUrl, vendor: {
                    vendorId, name: vendorName, country: vendorCountry
                }
            });

            // Assign Country to Brand
            if (!countriesByBrand.hasOwnProperty(brand)) {
                countriesByBrand[brand] = new Set();
            }
            countriesByBrand[brand].add(vendorCountry);

            brandVendorsByProductId[productId] = { brand, vendorCountry };
        }

        // With probability of 0.7 assign some previous Products to Vendor
        productsAssigned !== 0 && faker.helpers.maybe(() => {
            let productIds = Array.from({ length: productsAssigned - 1 }, (value, index) => index + 1);
            let productCountPerVendor = faker.number.int({ min: 0, max: 5 < productsAssigned ? 5 : productsAssigned - 1 });
            for (let j = 0; j < productCountPerVendor; j++) {
                const randomIndex = faker.number.int({ min: 0, max: productIds.length - 1 });
                const chosenProductId = productIds[randomIndex];

                vendorProducts.push(`(${vendorId}, ${chosenProductId})`);
                const brandCountry = brandVendorsByProductId[chosenProductId];
                countriesByBrand[brandCountry.brand].add(brandCountry.vendorCountry);

                productIds.splice(randomIndex, 1);
            }
        }, { probability: 0.7 });

        // Update productsAssigned count
        productsAssigned += productsPerVendor;

        // Assign Industries to Vendor
        vendorIndustries.push(
            ...faker.helpers.arrayElements(industryTypes, { max: 3 })
                .map(type => `(${vendorId}, ${type.typeId})`)
        );

        // Assign Contacts to Vendor
        const chosenContactTypes = faker.helpers.arrayElements(typeMapping.filter(type => type.typeFor === "contact"));
        chosenContactTypes.forEach(type => {
            const chosenContactValue = chooseContactValue(type.value);
            vendorObjects[vendorId - 1].contacts.push({ typeId: type.typeId, value: chosenContactValue, type: { value: type.value } });
            vendorContacts.push(`(${vendorId}, ${type.typeId}, '${chosenContactValue}')`);
        });
    }

    const relationalData = `INSERT INTO Vendor (vendorId, name, country) VALUES ${vendors.join(", \n")};\n` +
        `INSERT INTO Product (productId, asin, title, price, brand, imageUrl) VALUES ${products.join(", \n")};\n` +
        `INSERT INTO Vendor_Products (vendorId, productId) VALUES ${vendorProducts.join(", \n")};\n` +
        `INSERT INTO Industry (vendorId, typeId) VALUES ${vendorIndustries.join(", \n")};\n` +
        `INSERT INTO Vendor_Contacts (vendorId, typeId, value) VALUES ${vendorContacts.join(", \n")};\n`;

    const cassandraData = vendors.map(vendor => `INSERT INTO Vendor (vendorId, name, country) VALUES ${vendor};\n`).join("") +
        products.map(product => `INSERT INTO Product (productId, asin, title, price, brand, imageUrl) VALUES ${product};\n`).join("") +
        products.map(product => `INSERT INTO Products_By_Brand (productId, asin, title, price, brand, imageUrl) VALUES ${product};\n`).join("") +
        Object.keys(countriesByBrand).map(brand =>
            Array.from(countriesByBrand[brand]).map(country => `INSERT INTO Vendor_Countries_By_Product_Brand (brand, country) VALUES ('${brand}', '${country}');\n`).join("")
        ).join("");
    
    return { relationalData, cassandraData };
}

function generatePeople(peopleCount, customerCount = peopleCount, tagCount) {
    let people = [];
    let customers = [];
    let friends = [];
    let personTags = [];

    for (let i = 0; i < peopleCount; i++) {
        const personId = i + 1;
        const gender = faker.person.sexType();
        const firstName = faker.person.firstName(gender).replace(/'/g, "''");
        const lastName = faker.person.lastName(gender).replace(/'/g, "''");
        const birthday = faker.date.past({ years: 50 }).toISOString().substring(0, 10);
        const street = faker.location.streetAddress({ useFullAddress: true }).replace(/'/g, "''");
        const city = faker.location.city().replace(/'/g, "''");
        const postalCode = faker.location.zipCode();
        const country = faker.location.country().replace(/'/g, "''");

        peopleObjects.push({ personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friends: new Set(), tags: new Set(), ordersCreated: new Set([-1]) });
        people.push(`(${personId}, '${firstName}', '${lastName}', '${gender}', '${birthday}', '${street}', '${city}', '${postalCode}', '${country}')`);

        // Assign Friends to Person (Person_Person)
        let friendCount = faker.number.int({ min: 0, max: 10 });
        let friendIds = Array.from({ length: peopleCount }, (value, index) => index + 1);
        friendIds.splice(personId - 1, 1);
        for (let j = 0; j < friendCount; j++) {
            const randomIndex = faker.number.int({ min: 0, max: friendIds.length - 1 });
            const friendId = friendIds[randomIndex];

            peopleObjects[personId - 1].friends.add(friendId);
            friends.push(`(${personId}, ${friendId})`);

            friendIds.splice(randomIndex, 1);
        }

        // Assign Tags to Person (Person_Tags)
        let tagIds = Array.from({ length: tagCount }, (value, index) => index + 1);
        let tagCountPerPerson = faker.number.int({ min: 0, max: 10 });
        for (let j = 0; j < tagCountPerPerson; j++) {
            const randomIndex = faker.number.int({ min: 0, max: tagIds.length - 1 });
            const tagId = tagIds[randomIndex];

            peopleObjects[personId - 1].tags.add(tagId);
            tagObjects[tagId - 1].interestedPeople.add(personId).add(-1);
            personTags.push(`(${personId}, ${tagId})`);

            tagIds.splice(randomIndex, 1);
        }
    }

    for (let i = 0; i < customerCount; i++) {
        const customerId = i + 1;
        const personId = customerId;

        peopleObjects[i].customerId = customerId;
        customers.push(`(${customerId}, ${personId})`);
    }

    const relationalData = `INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country) VALUES ${people.join(", \n")};\n` +
        `INSERT INTO Customer (customerId, personId) VALUES ${customers.join(", \n")};\n` +
        `INSERT INTO Person_Person (personId1, personId2) VALUES ${friends.join(", \n")};\n` +
        `INSERT INTO Person_Tags (personId, tagId) VALUES ${personTags.join(", \n")};\n`;

    const cassandraData = peopleObjects.map(p => {
            const person = `(${p.personId}, '${p.firstName}', '${p.lastName}', '${p.gender}', '${p.birthday}', '${p.street}', '${p.city}', '${p.postalCode}', '${p.country}', ${p.friends.size})`;
            return `INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount) VALUES ${person};\n`;
        }).join("") +
        people.map(person => `INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode, country) VALUES ${person};\n`).join("");


    return { relationalData, cassandraData };
}

function generateOrders(customerCount, maxOrdersPerCustomer = 3, productCount, typeMapping, sqlFileName = 'data.sql', cqlFileName = 'data.cql') {
    let orders = [];
    let orderContacts = [];
    let orderProducts = [];

    const filteredContactTypes = typeMapping.filter(type => type.typeFor === "contact");

    let orderId = 1;
    for (let i = 0; i < customerCount; i++) {
        const customerId = i + 1;

        const orderCount = faker.number.int({ min: 1, max: maxOrdersPerCustomer });
        for (let j = 0; j < orderCount; j++) {
            orders.push(`(${orderId}, ${customerId})`);

            orderObjects.push({ orderId, customer: { customerId }, contacts: [], products: [] });

            // Assign Contacts to Order
            const chosenContactTypes = faker.helpers.arrayElements(filteredContactTypes, { min: 1 });
            chosenContactTypes.forEach(type => {
                const chosenContactValue = chooseContactValue(type.value);
                orderObjects[orderId - 1].contacts.push({ typeId: type.typeId, value: chosenContactValue, type: { value: type.value } })
                orderContacts.push(`(${orderId}, ${type.typeId}, '${chosenContactValue}')`);
            });

            // Assign Products to Order
            let productIdArray = Array.from({ length: productCount }, (value, index) => index + 1);
            let productsPerOrder = faker.number.int({ min: 1, max: 5 });
            for (let j = 0; j < productsPerOrder; j++) {
                const randomIndex = faker.number.int({ min: 0, max: productIdArray.length - 1 });
                const productId = productIdArray[randomIndex];
                const quantity = faker.number.int({ min: 1, max: 5 });

                orderObjects[orderId - 1].products.push({ productId, quantity });
                orderProducts.push(`(${orderId}, ${productId}, ${quantity})`);
                productIdArray.splice(randomIndex, 1);
            }

            orderId++;
        }
    }

    const relationalData = `INSERT INTO \`Order\` (orderId, customerId) VALUES ${orders.join(", \n")};\n` +
        `INSERT INTO Order_Contacts (orderId, typeId, value) VALUES ${orderContacts.join(", \n")};\n` +
        `INSERT INTO Order_Products (orderId, productId, quantity) VALUES ${orderProducts.join(", \n")};\n`;

    const cassandraData = generateCassandraOrderTables(cqlFileName);

    return { relationalData, cassandraData };
}

function generateCassandraOrderTables(cqlFileName) {
    let orderInserts = "";
    let ordersByProductInserts = "";
    let ordersByPerson = "";
    let ordersByCustomer = "";

    for (const { orderId, customer: { customerId }, products } of orderObjects) {
        const p = peopleObjects.find(person => person.customerId === customerId);

        // Orders_By_Person : ordersCreated set
        p.ordersCreated.delete(-1);
        p.ordersCreated.add(...products.map(p => p.productId));
        
        // "Order" and "Orders_By_Product" Cassandra tables
        for (const { productId, quantity } of products) {
            const { asin, title, price, brand, imageUrl } = productObjects.find(product => product.productId === productId);
            const v = productObjects.find(product => product.productId === productId).vendor;

            // "Order"
            const productValues = `${productId}, ${quantity}, '${asin}', '${title}', ${price}, '${brand}', '${imageUrl}'`;
            const orderValues =
                `(${orderId}, ${customerId}, ${p.personId}, '${p.firstName}', '${p.lastName}', '${p.gender}', '${p.birthday}', '${p.street}', 
                '${p.city}', '${p.postalCode}', '${p.country}', ${productValues}, ${v.vendorId}, '${v.name}', '${v.country}')`;
            orderInserts +=
                `INSERT INTO "Order" (orderId, customerId, personId, firstName, lastName, gender, birthday, street, city, postalCode,
                personCountry, productId, quantity, asin, title, price, brand, imageUrl, vendorId, vendorName,
                vendorCountry) VALUES ${orderValues};\n`;
            orderInserts = checkStringLengthAndAppendToFile(orderInserts, cqlFileName);
            
            // Orders_By_Product
            const ordersByProductValues = `(${productId}, '${asin}', '${title}', ${price}, '${brand}', '${imageUrl}', ${orderId}, ${quantity})`;
            ordersByProductInserts +=
                `INSERT INTO Orders_By_Product (productId, asin, title, price, brand, imageUrl, orderId, quantity) VALUES ${ordersByProductValues};\n`;
            ordersByProductInserts = checkStringLengthAndAppendToFile(ordersByProductInserts, cqlFileName);
        }

        // Orders_By_Customer
        ordersByCustomer += `INSERT INTO Orders_By_Customer (customerId, orderId) VALUES (${customerId}, ${orderId});\n`;
        ordersByCustomer = checkStringLengthAndAppendToFile(ordersByCustomer, cqlFileName);
    }

    // Orders_By_Person
    for (const { personId, firstName, lastName, ordersCreated } of peopleObjects) {
        const orderIdsSetString = Array.from(ordersCreated).map(id => id).join(", ");
        ordersByPerson += `INSERT INTO Orders_By_Person (personId, firstName, lastName, ordersCreated) VALUES (${personId}, '${firstName}', '${lastName}', { ${orderIdsSetString} });\n`;
        ordersByPerson = checkStringLengthAndAppendToFile(ordersByPerson, cqlFileName);
    }

    return orderInserts + ordersByProductInserts + ordersByPerson + ordersByCustomer;
}

function generateTags(tagCount = 100) {
    let tags = [];

    let randomTags = faker.helpers.uniqueArray(faker.lorem.word, tagCount);
    // faker.helpers.uniqueArray() can sometimes return less than the required number of unique elements
    // so we need to generate more tags to reach the required count
    randomTags.length < tagCount && randomTags.push(...faker.helpers.uniqueArray(() => faker.company.buzzNoun().replace(/'/g, "''"), tagCount - randomTags.length));
    randomTags = randomTags.length < tagCount ? randomTags.concat(Array.from({ length: tagCount - randomTags.length }, faker.string.nanoid)) : randomTags;
    
    randomTags.forEach((tag, index) => {
        tagObjects.push({ tagId: index + 1, value: tag, interestedPeople: new Set(), postsTagged: new Set() });
        tags.push(`(${index + 1}, '${tag}')`);
    });
    return `INSERT INTO Tag (tagId, value) VALUES ${tags.join(", \n")};\n`;
}

function generatePosts(postCount, peopleCount) {
    let posts = [];
    let postTags = [];

    for (let i = 0; i < postCount; i++) {
        const postId = i + 1;
        const personId = faker.number.int({ min: 1, max: peopleCount });
        const creationDate = faker.date.recent().toISOString().slice(0, -1);
        const language = faker.helpers.arrayElement(['English', 'Spanish', 'French', 'German', 'Chinese']);
        const postContent = postCount < 128000 ? faker.lorem.paragraphs({ min: 1, max: 5 }) : "";
        const postLength = postContent.length;
        posts.push(`(${postId}, ${personId}, '${faker.image.url()}', '${creationDate}', '${faker.internet.ip()}', '${faker.internet.userAgent()}', '${language}', '${postContent}', ${postLength})`);

        // Assign Tags to Post (Post_Tags)
        let tagIds = Array.from({ length: postCount }, (value, index) => index + 1);
        let tagCountPerPost = faker.number.int({ min: 0, max: 10 });
        for (let j = 0; j < tagCountPerPost; j++) {
            const randomIndex = faker.number.int({ min: 0, max: tagIds.length - 1 });
            const tagId = tagIds[randomIndex];

            tagObjects[tagId - 1].postsTagged.add(postId).add(-1);
            postTags.push(`(${postId}, ${tagId})`);
            tagIds.splice(randomIndex, 1);
        }
    }
    return `INSERT INTO Post (postId, personId, imageFile, creationDate, locationIP, browserUsed, language, content, length) VALUES ${posts.join(", \n")};\n` +
        `INSERT INTO Post_Tags (postId, tagId) VALUES ${postTags.join(", \n")};\n`;
}


function generateCassandraTagsContacts(cqlFileName = 'data.cql') {
    let tags = "";
    let contacts = "";
    
    // Tag table
    for (const { tagId, value, interestedPeople, postsTagged } of tagObjects) {
        const interestedPeopleSetString = Array.from(interestedPeople).map(id => id).join(", ");
        const postsTaggedSetString = Array.from(postsTagged).map(id => id).join(", ");
        tags += `INSERT INTO Tag (tagId, value, interestedPeople, postsTagged) VALUES (${tagId}, '${value}', { ${interestedPeopleSetString} }, { ${postsTaggedSetString} });\n`;
        tags = checkStringLengthAndAppendToFile(tags, cqlFileName);
    }

    // Contact table
    // Vendor Contacts
    for (const { vendorId, name, contacts: vendorContacts } of vendorObjects) {
        for (const { value: contactValue, type: { value: contactType } } of vendorContacts) {
            contacts += `INSERT INTO Contact (entityType, entityId, entityName, contactType, contactValue) VALUES ('Vendor', ${vendorId}, '${name}', '${capitalizeFirstLetter(contactType)}', '${contactValue}');\n`;
            contacts = checkStringLengthAndAppendToFile(contacts, cqlFileName);
        }
    }
    // Order Contacts
    for (const { orderId, customer: { customerId }, contacts: customerContacts } of orderObjects) {
        const { firstName, lastName } = peopleObjects.find(person => person.customerId === customerId);
        for (const { value: contactValue, type: { value: contactType } } of customerContacts) {
            const fullName = `${firstName} ${lastName}`;
            contacts += `INSERT INTO Contact (entityType, entityId, entityName, contactType, contactValue) VALUES ('Order', ${orderId}, '${fullName}', '${capitalizeFirstLetter(contactType)}', '${contactValue}');\n`;
            contacts = checkStringLengthAndAppendToFile(contacts, cqlFileName);
        }
    }

    return tags + contacts;
}

function writeCassandraOrderVendorContacts(cqlFileName = 'data.cql') {
    let orderVendorContactsByType = "";
    const dataFile = fs.openSync(cqlFileName, 'a');

    // Vendor_Contacts_By_Order_Contact table
    for (const { orderId, contacts: orderContacts } of orderObjects) {
        for (const { typeId, value: orderContactValue } of orderContacts) {
            for (const { vendorId, contacts: vendorContacts } of vendorObjects) {
                const vendorContactValue = vendorContacts.find(contact => contact.typeId === typeId)?.value;
                if (vendorContactValue) {
                    orderVendorContactsByType += `INSERT INTO Vendor_Contacts_By_Order_Contact (typeId, orderId, orderContactValue, vendorId, vendorContactValue) 
                        VALUES (${typeId}, ${orderId}, '${orderContactValue}', ${vendorId}, '${vendorContactValue}');\n`;
                    if (orderVendorContactsByType.length > 400000000) {
                        fs.appendFileSync(dataFile, orderVendorContactsByType);
                        orderVendorContactsByType = "";
                    }
                }
            }
        }
    }

    fs.closeSync(dataFile);
}

function generateData(recordCount = 100, sqlFileName = 'data.sql', cqlFileName = 'data.cql') {
    let relationalData = '';
    let cassandraData = 'USE ecommerce;\n\n';
    fs.writeFileSync(sqlFileName, relationalData);
    fs.writeFileSync(cqlFileName, cassandraData);

    const typeMapping = getTypeMapping();

    relationalData += generateTypes(typeMapping);

    let data = generateVendorsProducts(vendorCount = recordCount, productCount = recordCount, typeMapping);
    relationalData += data.relationalData;
    cassandraData += data.cassandraData;

    relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
    cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

    relationalData += generateTags(tagCount = recordCount);

    relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
    cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

    const peopleCount = recordCount;
    const customerCount = faker.number.int({ min: Math.floor(peopleCount / 2), max: peopleCount });
    data = generatePeople(peopleCount, customerCount, tagCount = recordCount);
    relationalData += data.relationalData;
    cassandraData += data.cassandraData;

    relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
    cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

    const maxOrdersPerCustomer = 3;
    data = generateOrders(customerCount, maxOrdersPerCustomer, productCount = recordCount, typeMapping, sqlFileName, cqlFileName);
    relationalData += data.relationalData;
    cassandraData += data.cassandraData;

    relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
    cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

    relationalData += generatePosts(postCount = recordCount, peopleCount);

    cassandraData += generateCassandraTagsContacts(cqlFileName);

    // Generating more than 1000 Vendor_Contacts_By_Order_Contact records causes data.cql to exceed 6GB 
    // in size and causes Cassandra to crash
    if (recordCount <= 1000) {
        // Flush current Cassandra data to file and clear buffer
        fs.writeFileSync(cqlFileName, cassandraData);
        cassandraData = '';

        writeCassandraOrderVendorContacts(cqlFileName);
    }

    return { relationalData, cassandraData };
}

function writeToFiles(data, sqlFileName = 'data.sql', cqlFileName = 'data.cql') {
    fs.appendFile(sqlFileName, data.relationalData, (err) => {
        if (err) throw err;
        console.log(`Relational data written to ${sqlFileName}`);
    });

    fs.appendFile(cqlFileName, data.cassandraData, (err) => {
        if (err) throw err;
        console.log(`Cassandra data written to ${cqlFileName}`);
    });
}

const recordCount = process.argv[2] || 1000;
const sqlFileName = process.argv[3] || "data_128k.sql";
const cqlFileName = process.argv[4] || "data_128k.cql";
writeToFiles(generateData(recordCount, sqlFileName, cqlFileName), sqlFileName, cqlFileName);
