import fs from 'fs';
import { DataStream, StringStream } from 'scramjet';

import { generateVendorsProducts, generateTags, generatePeople, generatePosts, generateOrders, getTypeMapping, chooseContactValue, cassandraTransformVendorProducts } from './generators';
import { mapToSQLDump, mapToTSV } from './transformers';
import { mapAndDump, mapAndDumpJSONLines } from './plugins';
import { CustomLogger, CustomFaker, capitalizeFirstLetter } from './utils';
import { STRING_MAX_ALLOWED_LENGTH, ARRAY_MAX_ALLOWED_LENGTH, MAX_VENDOR_PRODUCTS, fileNames } from './constants';
import { Vendor, Product, Person, Order, Tag, Type, ContactType, IndustryType } from './types';

// GLOBALS

const faker = CustomFaker.faker;
const logger = CustomLogger;
let OUTPUT_DIR: string;

// Utility functions

function checkStringLengthAndAppendToFile(data: string, filePath: string) {
    if (data.length >= STRING_MAX_ALLOWED_LENGTH) {
        fs.appendFileSync(filePath, data);
        return '';
    }
    return data;
}

function dumpRelationalObjectArrayToOutputFile(insertStatementPrefix: string, objects: object[], objectToInsertMapping: (o: object) => string, fileNameWithoutExt: string) {
    const data = objects.map(object => objectToInsertMapping(object)).join(", \n");
    fs.appendFileSync(`${OUTPUT_DIR}/${fileNameWithoutExt}.sql`, `${insertStatementPrefix} ${data};\n`);
}

function dumpCassandraObjectArrayToOutputFile(objects: object[], objectToInsertMapping: (o: object) => string, fileNameWithoutExt: string) {
    const data = objects.map(object => objectToInsertMapping(object)).join("");
    fs.appendFileSync(`${OUTPUT_DIR}/${fileNameWithoutExt}.cql`, data);
}

// SQLite, MySQL, Cassandra dummy data generator

let VENDOR_OBJECTS: Vendor[] = [];
let PRODUCT_OBJECTS: Product[] = [];
let PEOPLE_OBJECTS: Person[] = [];
let ORDER_OBJECTS: Order[] = [];
let TAG_OBJECTS: Tag[] = [];

function generateTypes(typeMapping) {
    logger.info(`Generating types for ${typeMapping.length} types`);

    let types = [];
    typeMapping.forEach(type => {
        types.push(`(${type.typeId}, '${type.value}')`);
    });
    return `INSERT INTO Type (typeId, value) VALUES ${types.join(", \n")};\n`;
}

function vendorProductStream(recordCount: number, typeMapping = getTypeMapping()) {
    const industryTypes = typeMapping.filter(type => type.typeFor === "industry") as IndustryType[];
    const contactTypes = typeMapping.filter(type => type.typeFor === "contact") as ContactType[];
    const vendorStream = DataStream
        .from(() => generateVendorsProducts(recordCount, recordCount, industryTypes, contactTypes))
        .tee(stream => {
            mapAndDump(
                stream,
                ({ vendorId, name, country }) => mapToTSV([vendorId, name, country]), 
                fileNames.vendors, 
                recordCount, 
                `${OUTPUT_DIR}/${fileNames.vendors}.tsv`,
            );
        })
        .tee(stream => {
            const industryTypeStream = stream.flatMap(
                ({ vendorId, industries }) => industries.map(({ typeId }) => ({ vendorId, industryId: typeId }))
            );
            mapAndDump(
                industryTypeStream,
                ({ vendorId, industryId }) => mapToTSV([vendorId, industryId]), 
                fileNames.industries, 
                null, 
                `${OUTPUT_DIR}/sql/${fileNames.industries}.tsv`,
            );
        })
        .tee(stream => {
            const contactTypeStream = stream.flatMap(
                ({ vendorId, contacts }) => contacts.map(({ typeId }) => ({ vendorId, contactId: typeId }))
            );
            mapAndDump(
                contactTypeStream,
                ({ vendorId, contactId }) => mapToTSV([vendorId, contactId]), 
                fileNames.vendorContacts, 
                null, 
                `${OUTPUT_DIR}/sql/${fileNames.vendorContacts}.tsv`,
            );
        })
        .tee(stream => {
            mapAndDumpJSONLines(
                stream,
                `${OUTPUT_DIR}/common/${fileNames.vendors}.jsonl`,
                false,
                ({ vendorId, name, country, contacts }) => ({ vendorId, name, country, contacts })
            );
        });
    const productStream = vendorStream
        .flatMap(({ products }) => products)
        // CQL 
        .tee(async (stream) => {
            const data = await cassandraTransformVendorProducts(stream);
            const countriesByBrandDenormalized = Object.keys(data.countriesByBrand).map(brand =>
                Array.from(data.countriesByBrand[brand]).map(country => ({ brand, country}))
            ).flat();
            
            mapAndDump(
                countriesByBrandDenormalized,
                ({ brand, country }) => mapToTSV([brand, country]),
                fileNames.vendorCountriesByProductBrand,
                null,
                `${OUTPUT_DIR}/cql/${fileNames.vendorCountriesByProductBrand}.tsv`
            );
        })
        // SQL Product table
        // CQL Product, Products_By_brand tables
        .tee(stream => {
            mapAndDump(
                stream,
                ({ productId, asin, title, price, brand, imageUrl }) => mapToTSV([productId, asin, title, price, brand, imageUrl]), 
                fileNames.products, 
                recordCount, 
                `${OUTPUT_DIR}/${fileNames.products}.tsv`
            );
        })
        .tee(stream => {
            mapAndDump(
                stream,
                ({ productId, vendor: { vendorId } }) => mapToTSV([vendorId, productId]), 
                fileNames.vendorProducts, 
                recordCount, 
                `${OUTPUT_DIR}/sql/${fileNames.vendorProducts}.tsv`
            )
        })
        .catch(logger.error);
    mapAndDumpJSONLines(
        productStream,
        `${OUTPUT_DIR}/common/${fileNames.products}.jsonl`,
    );
}

function peopleStream(peopleCount: number, customerCount = peopleCount, tagCount: number, tags?: Tag[]) {
    const peopleStream = DataStream
        .from(() => generatePeople(peopleCount, customerCount, tagCount, tags))
        // SQL Person, CQL Person_By_Birthday_Indexed tables
        .tee(stream => {
            mapAndDump(
                stream,
                ({ personId, gender, firstName, lastName, birthday, street, city, postalCode, country }) => mapToTSV([personId, gender, firstName, lastName, birthday, street, city, postalCode, country]),
                fileNames.people,
                peopleCount,
                `${OUTPUT_DIR}/${fileNames.people}.tsv`
            );
        })
        // CQL Person
        .tee(stream => {
            mapAndDump(
                stream,
                ({ personId, gender, firstName, lastName, birthday, street, city, postalCode, country, friends }) => mapToTSV([personId, gender, firstName, lastName, birthday, street, city, postalCode, country, friends.size]),
                fileNames.people,
                peopleCount,
                `${OUTPUT_DIR}/cql/${fileNames.people}.tsv`
            );
        })
        .tee(stream => {
            const personPersonStream = stream.flatMap(
                ({ personId, friends }) => Array.from(friends).map(friendId => ({ personId, friendId }))
            );
            mapAndDump(
                personPersonStream,
                ({ personId, friendId }) => mapToTSV([personId, friendId]),
                fileNames.personPerson,
                null,
                `${OUTPUT_DIR}/sql/${fileNames.personPerson}.tsv`
            );
        })
        .tee(stream => {
            const personTagsStream = stream.flatMap(
                ({ personId, tags }) => Array.from(tags).map(tagId => ({ personId, tagId }))
            );
            mapAndDump(
                personTagsStream,
                ({ personId, tagId }) => mapToTSV([personId, tagId]),
                fileNames.personTags,
                null,
                `${OUTPUT_DIR}/sql/${fileNames.personTags}.tsv`
            );
        })
        .catch(logger.error);
    return peopleStream;
    // mapAndDumpJSONLines(
    //     peopleStream,
    //     `${OUTPUT_DIR}/common/${fileNames.people}.jsonl`,
    //     true
    // );
}

function tagStream(tagCount = 100) {
    const tagStream = DataStream
        .from(() => generateTags(tagCount))
        .tee(stream => {
            mapAndDump(
                stream,
                ({ tagId, value }) => mapToTSV([tagId, value]),
                fileNames.tags,
                tagCount,
                `${OUTPUT_DIR}/${fileNames.tags}.tsv`
            );
        })
        .catch(logger.error);
    return tagStream;
    // return mapAndDumpJSONLines(
    //     tagStream,
    //     `${OUTPUT_DIR}/common/${fileNames.tags}.jsonl`,
    // );
}

function postStream(postCount: number, peopleCount: number, tags?: Tag[]) {
    const postStream = DataStream
        .from(() => generatePosts(postCount, peopleCount, tags))
        .tee(stream => {
            mapAndDump(
                stream,
                ({ postId, personId, imageFile, creationDate, locationIP, browserUsed, language, content, length }) => 
                    mapToTSV([postId, personId, imageFile, creationDate, locationIP, browserUsed, language, content, length]),
                fileNames.post,
                postCount,
                `${OUTPUT_DIR}/sql/${fileNames.post}.tsv`
            );
        })
        .tee(stream => {
            const postTagsStream = stream.flatMap(
                ({ postId, tags }) => Array.from(tags).map(tagId => ({ postId, tagId }))
            );
            mapAndDump(
                postTagsStream,
                ({ postId, tagId }) => mapToTSV([postId, tagId]),
                fileNames.postTags,
                null,
                `${OUTPUT_DIR}/sql/${fileNames.postTags}.tsv`
            );
        })
        .catch(logger.error);
    return postStream;
    // mapAndDumpJSONLines(
    //     postStream,
    //     `${OUTPUT_DIR}/common/${fileNames.post}.jsonl`,
    // );
}

function orderStream(customerCount: number, maxOrdersPerCustomer = 3, productCount: number, typeMapping: Type[]) {
    const contactTypes = typeMapping.filter(type => type.typeFor === "contact") as ContactType[];
    const orderStream = DataStream
        .from(() => generateOrders(customerCount, maxOrdersPerCustomer, productCount, contactTypes))
        .tee(stream => {
            mapAndDump(
                stream,
                ({ orderId, customer: { customerId } }) => mapToTSV([orderId, customerId]),
                fileNames.orders,
                productCount,
                `${OUTPUT_DIR}/sql/${fileNames.products}.tsv`
            );
        })
        .tee(stream => {
            const orderContactsStream = stream.flatMap(
                ({ orderId, contacts }) => contacts.map(({ typeId, value }) => ({ orderId, typeId, value }))
            );
            mapAndDump(
                orderContactsStream,
                ({ orderId, typeId, value }) => mapToTSV([orderId, typeId, value]),
                fileNames.orderContacts,
                null,
                `${OUTPUT_DIR}/sql/${fileNames.orderContacts}.tsv`
            );
        })
        .tee(stream => {
            const orderProductsStream = stream.flatMap(
                ({ orderId, products }) => products.map(({ productId, quantity }) => ({ orderId, productId, quantity }))
            );
            mapAndDump(
                orderProductsStream,
                ({ orderId, productId, quantity }) => mapToTSV([orderId, productId, quantity]),
                fileNames.orderProducts,
                null,
                `${OUTPUT_DIR}/sql/${fileNames.orderProducts}.tsv`
            );
        })
        .catch(logger.error);
    return orderStream;
}

function generateCassandraOrderTables(cqlFileName) {
    logger.info("Generating Cassandra tables:", "Orders_By_Customer", "Order", "Orders_By_Product", "Orders_By_Person");

    let orderInserts = "";
    let ordersByProductInserts = "";
    let ordersByPerson = "";
    let ordersByCustomer = "";

    for (const { orderId, customer: { customerId }, products } of ORDER_OBJECTS) {
        const p = PEOPLE_OBJECTS.find(person => person.customerId === customerId);

        // Orders_By_Person : ordersCreated set
        p.ordersCreated.delete(-1);
        // @ts-ignore
        p.ordersCreated.add(...products.map(p => p.productId) as const);

        // "Order" and "Orders_By_Product" Cassandra tables
        for (const { productId, quantity } of products) {
            const { asin, title, price, brand, imageUrl } = PRODUCT_OBJECTS.find(product => product.productId === productId);
            const v = PRODUCT_OBJECTS.find(product => product.productId === productId).vendor;

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
    for (const { personId, firstName, lastName, ordersCreated } of PEOPLE_OBJECTS) {
        const orderIdsSetString = Array.from(ordersCreated).map(id => id).join(", ");
        ordersByPerson += `INSERT INTO Orders_By_Person (personId, firstName, lastName, ordersCreated) VALUES (${personId}, '${firstName}', '${lastName}', { ${orderIdsSetString} });\n`;
        ordersByPerson = checkStringLengthAndAppendToFile(ordersByPerson, cqlFileName);
    }

    logger.info("Generated data for Cassandra tables:", "Orders_By_Customer", "Order", "Orders_By_Product", "Orders_By_Person");
    return orderInserts + ordersByProductInserts + ordersByPerson + ordersByCustomer;
}

function generateCassandraTagsContacts(cqlFileName = 'data.cql') {
    logger.info("Generating Cassandra tables:", "Tag", "Contact", "Vendor_Contacts_By_Order_Contact");

    let tags = "";
    let contacts = "";

    // Tag table
    for (const { tagId, value, interestedPeople, postsTagged } of TAG_OBJECTS) {
        const interestedPeopleSetString = Array.from(interestedPeople).map(id => id).join(", ");
        const postsTaggedSetString = Array.from(postsTagged).map(id => id).join(", ");
        tags += `INSERT INTO Tag (tagId, value, interestedPeople, postsTagged) VALUES (${tagId}, '${value}', { ${interestedPeopleSetString} }, { ${postsTaggedSetString} });\n`;
        tags = checkStringLengthAndAppendToFile(tags, cqlFileName);
    }

    // Contact table
    // Vendor Contacts
    for (const { vendorId, name, contacts: vendorContacts } of VENDOR_OBJECTS) {
        for (const { value: contactValue, type: { value: contactType } } of vendorContacts) {
            contacts += `INSERT INTO Contact (entityType, entityId, entityName, contactType, contactValue) VALUES ('Vendor', ${vendorId}, '${name}', '${capitalizeFirstLetter(contactType)}', '${contactValue}');\n`;
            contacts = checkStringLengthAndAppendToFile(contacts, cqlFileName);
        }
    }
    // Order Contacts
    for (const { orderId, customer: { customerId }, contacts: customerContacts } of ORDER_OBJECTS) {
        const { firstName, lastName } = PEOPLE_OBJECTS.find(person => person.customerId === customerId);
        for (const { value: contactValue, type: { value: contactType } } of customerContacts) {
            const fullName = `${firstName} ${lastName}`;
            contacts += `INSERT INTO Contact (entityType, entityId, entityName, contactType, contactValue) VALUES ('Order', ${orderId}, '${fullName}', '${capitalizeFirstLetter(contactType)}', '${contactValue}');\n`;
            contacts = checkStringLengthAndAppendToFile(contacts, cqlFileName);
        }
    }

    logger.info("Generated data for Cassandra tables:", "Tag", "Contact");
    return tags + contacts;
}

function writeCassandraOrderVendorContacts(cqlFileName = 'data.cql') {
    logger.info("Generating Cassandra table:", "Vendor_Contacts_By_Order_Contact");

    let orderVendorContactsByType = "";
    const dataFile = fs.openSync(cqlFileName, 'a');

    // Vendor_Contacts_By_Order_Contact table
    for (const { orderId, contacts: orderContacts } of ORDER_OBJECTS) {
        for (const { typeId, value: orderContactValue } of orderContacts) {
            for (const { vendorId, contacts: vendorContacts } of VENDOR_OBJECTS) {
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

    logger.info("Generated data for Cassandra table:", "Vendor_Contacts_By_Order_Contact");
    fs.closeSync(dataFile);
}

// function generateData(recordCount = 100, sqlFileName = 'data.sql', cqlFileName = 'data.cql') {
//     let relationalData = '';
//     let cassandraData = 'USE ecommerce;\n\n';
//     fs.writeFileSync(sqlFileName, relationalData);
//     fs.writeFileSync(cqlFileName, cassandraData);

//     const typeMapping = getTypeMapping();

//     relationalData += generateTypes(typeMapping);

//     let data;
//     data = generateVendorsProductss(recordCount, recordCount, typeMapping);
//     relationalData += data.relationalData;
//     cassandraData += data.cassandraData;

//     relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
//     cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

//     relationalData += generateTags(recordCount);

//     relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
//     cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

//     const peopleCount = recordCount;
//     const customerCount = faker.number.int({ min: Math.floor(peopleCount / 2), max: peopleCount });
//     data = generatePeople(peopleCount, customerCount, recordCount);
//     relationalData += data.relationalData;
//     cassandraData += data.cassandraData;

//     relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
//     cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

//     const maxOrdersPerCustomer = 3;
//     const productCount = recordCount;
//     data = generateOrders(customerCount, maxOrdersPerCustomer, productCount, typeMapping, sqlFileName, cqlFileName);
//     relationalData += data.relationalData;
//     cassandraData += data.cassandraData;

//     relationalData = checkStringLengthAndAppendToFile(relationalData, sqlFileName);
//     cassandraData = checkStringLengthAndAppendToFile(cassandraData, cqlFileName);

//     const postCount = recordCount;
//     relationalData += generatePosts(postCount, peopleCount);

//     // cassandraData += generateCassandraTagsContacts(cqlFileName);

//     // Generating more than 1000 Vendor_Contacts_By_Order_Contact records causes data.cql to exceed 6GB 
//     // in size and causes Cassandra to crash
//     // if (recordCount <= 1000) {
//     //     // Flush current Cassandra data to file and clear buffer
//     //     fs.writeFileSync(cqlFileName, cassandraData);
//     //     cassandraData = '';

//     //     writeCassandraOrderVendorContacts(cqlFileName);
//     // }

//     return { relationalData, cassandraData };
// }

async function cassandraTagPersonPostPipeline(recordCount: number) {
    // const typeMapping = getTypeMapping();
    // vendorProductStream(recordCount, typeMapping);
    
    const tagStreamOut = tagStream(recordCount);
    const tags: Tag[] = await 
        // StringStream.from(fs.createReadStream(`${OUTPUT_DIR}/common/${fileNames.tags}.jsonl`, 'utf-8'))
        tagStreamOut
        // .JSONParse()
        .map((obj: Tag) => ({...obj, interestedPeople: new Set(), postsTagged: new Set()}))
        .toArray();

    const customerCount = faker.number.int({ min: Math.floor(recordCount / 2), max: recordCount });
    peopleStream(recordCount, customerCount, recordCount, tags);
    postStream(recordCount, recordCount, tags);

    // Write updated tags to file
    mapAndDumpJSONLines(
        DataStream.from(tags),
        `${OUTPUT_DIR}/common/${fileNames.tags}_updated.jsonl`,
        true
    );
}

function main() {
    const isDataDirSet = process.argv.length > 1;
    if (isDataDirSet) {
        const recordCount = parseInt(process.argv[2]);

        const currentDateTime = new Date();
        CustomLogger.initialize(currentDateTime, recordCount, 5);
        CustomFaker.initialize();
        
        OUTPUT_DIR = `data_${recordCount}_${currentDateTime.toISOString().replace(/:/g, "-")}`;

        fs.mkdirSync(`${OUTPUT_DIR}/common`, { recursive: true });
        fs.mkdirSync(`${OUTPUT_DIR}/sql`, { recursive: true });
        fs.mkdirSync(`${OUTPUT_DIR}/cql`, { recursive: true });

        // plugin(require('./plugins'));

        logger.info(`Started generating data for ${recordCount} records`);
        // writeToFiles(generateData(parseInt(process.argv[2]), sqlFileName, cqlFileName), sqlFileName, cqlFileName);

        const typeMapping = getTypeMapping();
        vendorProductStream(recordCount, typeMapping);

        // tagStream(recordCount);
        const customerCount = faker.number.int({ min: Math.floor(recordCount / 2), max: recordCount });
        // peopleStream(recordCount, customerCount, recordCount);
        // postStream(recordCount, recordCount);

        // cassandraTagPersonPostPipeline(recordCount);
        // orderStream(customerCount, 3, recordCount, typeMapping);
    } else {
        console.log("Please provide the record count as an argument");
        process.exit(1);
    }
}

main();
