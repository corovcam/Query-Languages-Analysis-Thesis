const fs = require('fs');
const { faker } = require('@faker-js/faker');

faker.seed(123);
faker.setDefaultRefDate('2000-01-01T00:00:00.000Z');

// Utility functions

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

// SQLite, MySQL, Cassandra dummy data generator

function getTypeMapping(industryCount = 10, contactTypes = ["Email", "Phone", "Address"]) {
    const industryTypes = faker.helpers.uniqueArray(faker.commerce.department, industryCount);
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

    let productsAssigned = 0;
    for (let i = 0; i < vendorCount; i++) {
        const vendorId = i + 1;
        const vendorName = faker.company.name().replace(/'/g, "''");
        const vendorCountry = faker.location.country().replace(/'/g, "''");
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

            // Assign Country to Brand
            if (!countriesByBrand[brand]) {
                countriesByBrand[brand] = new Set();
            }
            countriesByBrand[brand].add(vendorCountry);

            brandVendorsByProductId[productId] = { brand, vendorCountry };
        }

        // TODO: Fix for Cassandra
        // With probability of 0.3 assign some previous Products to Vendor
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
            ...faker.helpers.arrayElements(typeMapping.filter(type => type.typeFor === "industry"), { max: 3 })
                .map(type => `(${vendorId}, ${type.typeId})`)
        );

        // Assign Contacts to Vendor
        const chosenContactTypes = faker.helpers.arrayElements(typeMapping.filter(type => type.typeFor === "contact"));
        chosenContactTypes.forEach(type => {
            vendorContacts.push(`(${vendorId}, ${type.typeId}, '${chooseContactValue(type.value)}')`);
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

    let peopleObjects = [];

    for (let i = 0; i < peopleCount; i++) {
        const personId = i + 1;
        const sexType = faker.person.sexType();
        const firstName = faker.person.firstName(sexType).replace(/'/g, "''");
        const lastName = faker.person.lastName(sexType).replace(/'/g, "''");
        const birthday = faker.date.past({ years: 50 }).toISOString().substring(0, 10);
        const streetAddress = faker.location.streetAddress({ useFullAddress: true }).replace(/'/g, "''");
        const city = faker.location.city().replace(/'/g, "''");
        const postalCode = faker.location.zipCode();
        const country = faker.location.country().replace(/'/g, "''");
        
        peopleObjects.push({ personId, firstName, lastName, sexType, birthday, streetAddress, city, postalCode, country, friends: [], tags: [] });
        people.push(`(${personId}, '${firstName}', '${lastName}', '${sexType}', '${birthday}', '${streetAddress}', '${city}', '${postalCode}', '${country}')`);

        // Assign Friends to Person (Person_Person)
        let friendCount = faker.number.int({ min: 0, max: 10 });
        let friendIds = Array.from({ length: peopleCount }, (value, index) => index + 1);
        friendIds.splice(personId - 1, 1);
        for (let j = 0; j < friendCount; j++) {
            const randomIndex = faker.number.int({ min: 0, max: friendIds.length - 1 });
            const friendId = friendIds[randomIndex];
            peopleObjects[personId - 1].friends.push(friendId);
            friends.push(`(${personId}, ${friendId})`);
            friendIds.splice(randomIndex, 1);
        }

        // Assign Tags to Person (Person_Tags)
        let tagIds = Array.from({ length: tagCount }, (value, index) => index + 1);
        let tagCountPerPerson = faker.number.int({ min: 0, max: 10 });
        for (let j = 0; j < tagCountPerPerson; j++) {
            const randomIndex = faker.number.int({ min: 0, max: tagIds.length - 1 });
            const tagId = tagIds[randomIndex];
            peopleObjects[personId - 1].tags.push(tagId);
            tagIds.splice(randomIndex, 1);
        }
    }

    for (let i = 0; i < customerCount; i++) {
        const customerId = i + 1;
        const personId = customerId;
        customers.push(`(${customerId}, ${personId})`);
    }

    const relationalData = `INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country) VALUES ${people.join(", \n")};\n` +
        `INSERT INTO Customer (customerId, personId) VALUES ${customers.join(", \n")};\n` +
        `INSERT INTO Person_Person (personId1, personId2) VALUES ${friends.join(", \n")};\n` +
        `INSERT INTO Person_Tags (personId, tagId) VALUES ${personTags.join(", \n")};\n`;
    
    const cassandraData = peopleObjects.map(p => {
            const person = `(${p.personId}, '${p.firstName}', '${p.lastName}', '${p.sexType}', '${p.birthday}', '${p.streetAddress}', '${p.city}', '${p.postalCode}', '${p.country}', ${p.friends.length})`;
            return `INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount) VALUES ${person};\n`
        }
        ).join("") +
        people.map(person => `INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode, country) VALUES ${person};\n`).join("");


    return { relationalData, cassandraData };
}

function generateOrders(customerCount, maxOrdersPerCustomer = 3, productCount, typeMapping) {
    let orders = [];
    let orderContacts = [];
    let orderProducts = [];

    // TODO: Handle random product assignment ?
    const filteredContactTypes = typeMapping.filter(type => type.typeFor === "contact");

    let orderId = 1;
    for (let i = 0; i < customerCount; i++) {
        const customerId = i + 1;

        const orderCount = faker.number.int({ min: 1, max: maxOrdersPerCustomer });
        for (let j = 0; j < orderCount; j++) {
            orders.push(`(${orderId}, ${customerId})`);

            // Assign Contacts to Order
            const chosenContactTypes = faker.helpers.arrayElements(filteredContactTypes, { min: 1 });
            chosenContactTypes.forEach(type => {
                orderContacts.push(`(${orderId}, ${type.typeId}, '${chooseContactValue(type.value)}')`);
            });

            // Assign Products to Order
            let productIdArray = Array.from({ length: productCount }, (value, index) => index + 1);
            let productsPerOrder = faker.number.int({ min: 1, max: 5 });
            for (let j = 0; j < productsPerOrder; j++) {
                const randomIndex = faker.number.int({ min: 0, max: productIdArray.length - 1 });
                const productId = productIdArray[randomIndex];
                const quantity = faker.number.int({ min: 1, max: 5 });
                orderProducts.push(`(${orderId}, ${productId}, ${quantity})`);
                productIdArray.splice(randomIndex, 1);
            }

            orderId++;
        }
    }
    return `INSERT INTO \`Order\` (orderId, customerId) VALUES ${orders.join(", \n")};\n` +
        `INSERT INTO Order_Contacts (orderId, typeId, value) VALUES ${orderContacts.join(", \n")};\n` +
        `INSERT INTO Order_Products (orderId, productId, quantity) VALUES ${orderProducts.join(", \n")};\n`;
}

function generateTags(tagCount = 100) {
    let tags = [];
    const randomTags = faker.helpers.uniqueArray(faker.lorem.word, tagCount);
    randomTags.forEach((tag, index) => {
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
        const postContent = faker.lorem.paragraphs({ min: 1, max: 5 });
        const postLength = postContent.length;
        posts.push(`(${postId}, ${personId}, '${faker.image.url()}', '${creationDate}', '${faker.internet.ip()}', '${faker.internet.userAgent()}', '${language}', '${postContent}', ${postLength})`);

        // Assign Tags to Post (Post_Tags)
        let tagIds = Array.from({ length: postCount }, (value, index) => index + 1);
        let tagCountPerPost = faker.number.int({ min: 0, max: 10 });
        for (let j = 0; j < tagCountPerPost; j++) {
            const randomIndex = faker.number.int({ min: 0, max: tagIds.length - 1 });
            const tagId = tagIds[randomIndex];
            postTags.push(`(${postId}, ${tagId})`);
            tagIds.splice(randomIndex, 1);
        }
    }
    return `INSERT INTO Post (postId, personId, imageFile, creationDate, locationIP, browserUsed, language, content, length) VALUES ${posts.join(", \n")};\n` +
        `INSERT INTO Post_Tags (postId, tagId) VALUES ${postTags.join(", \n")};\n`;
}

function generateData(recordCount = 100) {
    let relationalData = '';
    let cassandraData = 'USE ecommerce;\n\nBEGIN BATCH\n';

    const typeMapping = getTypeMapping();

    relationalData += generateTypes(typeMapping);

    let data = generateVendorsProducts(vendorCount = recordCount, productCount = recordCount, typeMapping);
    relationalData += data.relationalData;
    cassandraData += data.cassandraData;

    relationalData += generateTags(tagCount = recordCount);

    const peopleCount = recordCount;
    const customerCount = faker.number.int({ min: Math.floor(peopleCount / 2), max: peopleCount });
    data = generatePeople(peopleCount, customerCount, tagCount = recordCount);
    relationalData += data.relationalData;
    cassandraData += data.cassandraData;

    const maxOrdersPerCustomer = 3;
    relationalData += generateOrders(customerCount, maxOrdersPerCustomer, productCount = recordCount, typeMapping);

    relationalData += generatePosts(postCount = recordCount, peopleCount);

    cassandraData += '\nAPPLY BATCH;';

    return { relationalData, cassandraData };
}

function writeToFiles(data) {
    fs.writeFile('data_new.sql', data.relationalData, (err) => {
        if (err) throw err;
        console.log("Relational data written to data_new.sql");
    });

    fs.writeFile('data_new.cql', data.cassandraData, (err) => {
        if (err) throw err;
        console.log("Cassandra data written to data_new.cql");
    });
}

writeToFiles(generateData(100));
