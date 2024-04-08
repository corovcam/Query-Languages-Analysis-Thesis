import fs from 'fs';
import { DataStream } from 'scramjet';

import { generateVendorsProducts, generateTags, generatePeople, generatePosts, generateOrders, generateTypeMapping } from './generators';
import { mapToCSV, mapAndDump } from './transformers';
import { CustomLogger, CustomFaker } from './utils';
import { fileNames } from './constants';
import { Tag, Type, ContactType, IndustryType } from './types';

// GLOBALS

const faker = CustomFaker.faker;
const logger = CustomLogger;
let OUTPUT_DIR: string;

// SQLite, MySQL dummy data generator

function typeStream(): Promise<Type[]> {
    const typeMappingPromise = DataStream
        .from(generateTypeMapping())
        // SQL Type
        .tee(stream => {
            mapAndDump(
                stream,
                ({ typeId, value }) => mapToCSV([typeId, value]),
                fileNames.types,
                null,
                `${OUTPUT_DIR}/${fileNames.types}.csv`
            );
        })
        .toArray();
    return typeMappingPromise;
}

function vendorProductStream(recordCount: number, typeMapping: Type[]) {
    const industryTypes = typeMapping.filter(type => type.typeFor === "industry") as IndustryType[];
    const contactTypes = typeMapping.filter(type => type.typeFor === "contact") as ContactType[];
    const vendorStream = DataStream
        .from(() => generateVendorsProducts(recordCount, recordCount, industryTypes, contactTypes))
        // SQL Vendor
        .tee(stream => {
            mapAndDump(
                stream,
                ({ vendorId, name, country }) => mapToCSV([vendorId, name, country]), 
                fileNames.vendors, 
                recordCount, 
                `${OUTPUT_DIR}/${fileNames.vendors}.csv`,
            );
        })
        // SQL Industry
        .tee(stream => {
            const industryTypeStream = stream.flatMap(
                ({ vendorId, industries }) => industries.map(({ typeId }) => ({ vendorId, industryId: typeId }))
            );
            mapAndDump(
                industryTypeStream,
                ({ vendorId, industryId }) => mapToCSV([vendorId, industryId]), 
                fileNames.industries, 
                null, 
                `${OUTPUT_DIR}/${fileNames.industries}.csv`,
            );
        })
        // SQL Vendor_Contacts
        .tee(stream => {
            const contactTypeStream = stream.flatMap(
                ({ vendorId, contacts }) => contacts.map(({ typeId, value }) => ({ vendorId, contactId: typeId, value }))
            );
            mapAndDump(
                contactTypeStream,
                ({ vendorId, contactId, value }) => mapToCSV([vendorId, contactId, value]), 
                fileNames.vendorContacts, 
                null, 
                `${OUTPUT_DIR}/${fileNames.vendorContacts}.csv`,
            );
        })
        // .tee(stream => {
        //     mapAndDumpJSONLines(
        //         stream,
        //         `${OUTPUT_DIR}/common/${fileNames.vendors}.jsonl`,
        //         false,
        //         ({ vendorId, name, country, contacts }) => ({ vendorId, name, country, contacts })
        //     );
        // });
    const productStream = vendorStream
        .flatMap(({ products }) => products)
        // SQL Product
        .tee(stream => {
            mapAndDump(
                stream,
                ({ productId, asin, title, price, brand, imageUrl }) => mapToCSV([productId, asin, title, price, brand, imageUrl]), 
                fileNames.products, 
                recordCount, 
                `${OUTPUT_DIR}/${fileNames.products}.csv`
            );
        })
        // SQL Vendor_Products
        .tee(stream => {
            mapAndDump(
                stream,
                ({ productId, vendor: { vendorId } }) => mapToCSV([vendorId, productId]), 
                fileNames.vendorProducts, 
                recordCount, 
                `${OUTPUT_DIR}/${fileNames.vendorProducts}.csv`
            )
        })
        .catch(logger.error);
    return productStream.whenEnd();
    // return mapAndDumpJSONLines(
    //     productStream,
    //     `${OUTPUT_DIR}/common/${fileNames.products}.jsonl`,
    // );
}

function peopleStream(peopleCount: number, customerCount = peopleCount, tagCount: number, tags?: Tag[]) {
    const peopleStream = DataStream
        .from(() => generatePeople(peopleCount, customerCount, tagCount, tags))
        // SQL Person
        .tee(stream => {
            mapAndDump(
                stream,
                ({ personId, gender, firstName, lastName, birthday, street, city, postalCode, country }) => mapToCSV([personId, gender, firstName, lastName, birthday, street, city, postalCode, country]),
                fileNames.people,
                peopleCount,
                `${OUTPUT_DIR}/${fileNames.people}.csv`
            );
        })
        // SQL Customer
        .tee(stream => {
            const customerStream = stream.filter(({ customerId }) => customerId !== undefined);
            mapAndDump(
                customerStream,
                ({ personId, customerId }) => mapToCSV([customerId, personId]),
                fileNames.customer,
                customerCount,
                `${OUTPUT_DIR}/${fileNames.customer}.csv`
            );
        })
        // SQL Person_Tags
        .tee(stream => {
            const personTagsStream = stream.flatMap(
                ({ personId, tags }) => Array.from(tags).map(tagId => ({ personId, tagId }))
            );
            mapAndDump(
                personTagsStream,
                ({ personId, tagId }) => mapToCSV([personId, tagId]),
                fileNames.personTags,
                null,
                `${OUTPUT_DIR}/${fileNames.personTags}.csv`
            );
        })
        // SQL Person_Person
        .tee(stream => {
            const personPersonStream = stream.flatMap(
                ({ personId, friends }) => Array.from(friends).map(friendId => ({ personId, friendId }))
            );
            mapAndDump(
                personPersonStream,
                ({ personId, friendId }) => mapToCSV([personId, friendId]),
                fileNames.personPerson,
                null,
                `${OUTPUT_DIR}/${fileNames.personPerson}.csv`
            );
        })
        .catch(logger.error);
    return peopleStream.whenEnd();
    // mapAndDumpJSONLines(
    //     peopleStream,
    //     `${OUTPUT_DIR}/common/${fileNames.people}.jsonl`,
    //     true
    // );
}

function tagStream(tagCount = 100) {
    const tagStream = DataStream
        .from(() => generateTags(tagCount))
        // SQL Tag
        .tee(stream => {
            mapAndDump(
                stream,
                ({ tagId, value }) => mapToCSV([tagId, value]),
                fileNames.tags,
                tagCount,
                `${OUTPUT_DIR}/${fileNames.tags}.csv`
            );
        })
        .catch(logger.error);
    return tagStream.whenEnd();
    // return mapAndDumpJSONLines(
    //     tagStream,
    //     `${OUTPUT_DIR}/common/${fileNames.tags}.jsonl`,
    // );
}

function postStream(postCount: number, peopleCount: number, tags?: Tag[]) {
    const postStream = DataStream
        .from(() => generatePosts(postCount, peopleCount, tags))
        // SQL Post
        .tee(stream => {
            mapAndDump(
                stream,
                ({ postId, personId, imageFile, creationDate, locationIP, browserUsed, language, content, length }) => 
                    mapToCSV([postId, personId, imageFile, creationDate, locationIP, browserUsed, language, content, length]),
                fileNames.post,
                postCount,
                `${OUTPUT_DIR}/${fileNames.post}.csv`
            );
        })
        // SQL Post_Tags
        .tee(stream => {
            const postTagsStream = stream.flatMap(
                ({ postId, tags }) => Array.from(tags).map(tagId => ({ postId, tagId }))
            );
            mapAndDump(
                postTagsStream,
                ({ postId, tagId }) => mapToCSV([postId, tagId]),
                fileNames.postTags,
                null,
                `${OUTPUT_DIR}/${fileNames.postTags}.csv`
            );
        })
        .catch(logger.error);
    return postStream.whenEnd();
    // mapAndDumpJSONLines(
    //     postStream,
    //     `${OUTPUT_DIR}/common/${fileNames.post}.jsonl`,
    // );
}

function orderStream(customerCount: number, maxOrdersPerCustomer = 3, productCount: number, typeMapping: Type[]) {
    const contactTypes = typeMapping.filter(type => type.typeFor === "contact") as ContactType[];
    const orderStream = DataStream
        .from(() => generateOrders(customerCount, maxOrdersPerCustomer, productCount, contactTypes))
        // SQL Order
        .tee(stream => {
            mapAndDump(
                stream,
                ({ orderId, customer: { customerId } }) => mapToCSV([orderId, customerId]),
                fileNames.orders,
                productCount,
                `${OUTPUT_DIR}/${fileNames.orders}.csv`
            );
        })
        // SQL Order_Contacts
        .tee(stream => {
            const orderContactsStream = stream.flatMap(
                ({ orderId, contacts }) => contacts.map(({ typeId, value }) => ({ orderId, typeId, value }))
            );
            mapAndDump(
                orderContactsStream,
                ({ orderId, typeId, value }) => mapToCSV([orderId, typeId, value]),
                fileNames.orderContacts,
                null,
                `${OUTPUT_DIR}/${fileNames.orderContacts}.csv`
            );
        })
        // SQL Order_Products
        .tee(stream => {
            const orderProductsStream = stream.flatMap(
                ({ orderId, products }) => products.map(({ productId, quantity }) => ({ orderId, productId, quantity }))
            );
            mapAndDump(
                orderProductsStream,
                ({ orderId, productId, quantity }) => mapToCSV([orderId, productId, quantity]),
                fileNames.orderProducts,
                null,
                `${OUTPUT_DIR}/${fileNames.orderProducts}.csv`
            );
        })
        .catch(logger.error);
    return orderStream.whenEnd();
}

async function main() {
    const isDataDirSet = process.argv.length > 1;
    if (isDataDirSet) {
        const recordCount = parseInt(process.argv[2]);

        const currentDateTime = new Date();
        CustomLogger.initialize(currentDateTime, recordCount, 5);
        CustomFaker.initialize();
        
        OUTPUT_DIR = `data_${recordCount}_${currentDateTime.toISOString().replace(/:/g, "-")}`;

        fs.mkdirSync(`${OUTPUT_DIR}/common`, { recursive: true });
        fs.mkdirSync(`${OUTPUT_DIR}`, { recursive: true });

        logger.info(`Started generating data for ${recordCount} records`);
        const typeMapping = await typeStream();
        logger.info("Finished generating types.");
        await vendorProductStream(recordCount, typeMapping);
        logger.info("Finished generating vendors and products.");
        await tagStream(recordCount);
        logger.info("Finished generating tags.");
        const customerCount = faker.number.int({ min: Math.floor(recordCount / 2), max: recordCount });
        await peopleStream(recordCount, customerCount, recordCount);
        logger.info("Finished generating people.");
        await postStream(recordCount, recordCount);
        logger.info("Finished generating posts.");
        await orderStream(customerCount, 3, recordCount, typeMapping);
        logger.info("Finished generating orders.");
    } else {
        console.log("Please provide the record count as an argument");
        process.exit(1);
    }
}

main();
