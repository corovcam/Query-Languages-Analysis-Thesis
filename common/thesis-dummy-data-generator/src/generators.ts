import { CustomLogger as logger, CustomFaker, capitalizeFirstLetter } from './utils';
import { STRING_MAX_ALLOWED_LENGTH, ARRAY_MAX_ALLOWED_LENGTH, MAX_VENDOR_PRODUCTS, fileNames } from './constants';
import { Vendor, Product, Person, Order, Tag, Type, ContactType, IndustryType, brandVendorsByProductId, countriesByBrand } from './types';
import { DataStream } from 'scramjet';

const faker = CustomFaker.faker;

export function getTypeMapping(industryCount = 10, contactTypes = ["Email", "Phone", "Address"]) {
  const industryTypes = faker.helpers.uniqueArray(() => faker.commerce.department().replace(/'/g, "''"), industryCount);
  let typeMapping = contactTypes.map((type, index) => ({ typeId: index + 1, typeFor: "contact", value: type }));
  typeMapping.push(...industryTypes.map((type, index) => ({ typeId: index + 1 + contactTypes.length, typeFor: "industry", value: type })));
  return typeMapping as Type[];
}

export function chooseContactValue(type: ContactType["value"] | string): string {
  switch (type.toLowerCase()) {
      case "email":
          return faker.internet.email();
      case "phone":
          return faker.phone.number();
      case "address":
          return `${faker.location.streetAddress({ useFullAddress: true }).replace(/'/g, "''")}, ${faker.location.city().replace(/'/g, "''")}, ${faker.location.country().replace(/'/g, "''")}`;
      default:
          return "";
  }
}

export async function* generateVendorsProducts(vendorCount = 100, productCount = 1000, industryTypes: IndustryType[], contactTypes: ContactType[]): AsyncGenerator<Vendor> {
  logger.info(`Generating data for ${vendorCount} vendors and ${productCount} products`);
  let productsAssigned = 0;
  for (let i = 0; i < vendorCount; i++) {
      const vendorId = i + 1;
      const vendorName = faker.company.name().replace(/'/g, "''");
      const vendorCountry = faker.location.country().replace(/'/g, "''");

      const vendor: Vendor = { vendorId, name: vendorName, country: vendorCountry, products: [], industries: [], contacts: [] };

      // Assign Products to Vendor
      let productsPerVendor = faker.number.int({ max: MAX_VENDOR_PRODUCTS });
      const productsAssignable = productCount - productsAssigned;
      if (productsPerVendor > productsAssignable) {
          productsPerVendor = productsAssignable;
      }

      for await (const product of generateProductsForVendor(vendor, productsPerVendor, productsAssigned)) {
          vendor.products.push(product);
      }

      // Update productsAssigned count
      productsAssigned += productsPerVendor;

      // Assign Industries to Vendor
      faker.helpers.arrayElements(industryTypes, { min: 1, max: 3 }).forEach(type => vendor.industries.push(type));

      // Assign Contacts to Vendor
      const chosenContactTypes = faker.helpers.arrayElements(contactTypes);
      chosenContactTypes.forEach(type => {
          const chosenContactValue = chooseContactValue(type.value);
          const contact = { typeId: type.typeId, value: chosenContactValue, type: { value: type.value } };
          vendor.contacts.push(contact);
      });

      if (i % logger.batchSizeToLog === 0) {
          logger.info(`Generated ${i + 1} vendors and ${productsAssigned} products`);
      }

      yield vendor;
  }
  logger.info(`Generated data for ${vendorCount} vendors and ${productsAssigned} products`);
}

async function* generateProductsForVendor(vendor: Vendor, productsPerVendor: number, productsAssigned: number): AsyncGenerator<Product> {
  for (let i = productsAssigned; i < productsAssigned + productsPerVendor; i++) {
    const productId = i + 1;
    const asin = faker.string.nanoid(10).toUpperCase();
    const title = faker.commerce.productName().replace(/'/g, "''");
    const price = faker.commerce.price();
    const brand = faker.helpers.weightedArrayElement([
        { weight: 0.8, value: vendor.name },
        { weight: 0.2, value: capitalizeFirstLetter(faker.lorem.word()) }
    ]);
    const imageUrl = faker.image.url();

    const product: Product = {
      productId, asin, title, price, brand, imageUrl, vendor: {
        vendorId: vendor.vendorId, name: vendor.name, country: vendor.country
      }
    };

    if (i % logger.batchSizeToLog === 0) {
      logger.info(`Generated ${i + 1} products for vendor ${vendor.vendorId}`);
    }
    
    yield product;
  }
}

export async function* generatePeople(peopleCount: number, customerCount = peopleCount, tagCount: number) {
  logger.info(`Generating data for ${peopleCount} people and ${customerCount} customers`);

  // TODO: ENOURMOUSLY INNEFECTIVE - O(22n^2) algorithm - need to erase Array allocations, splice method and rewrite to Stream processing
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

      const person: Person = { personId, gender, firstName, lastName, birthday, street, city, postalCode, country, friends: new Set(), tags: new Set(), ordersCreated: new Set([-1]) };

      // PEOPLE_OBJECTS.push({ personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friends: new Set(), tags: new Set(), ordersCreated: new Set([-1]) });
      // people.push(`(${personId}, '${firstName}', '${lastName}', '${gender}', '${birthday}', '${street}', '${city}', '${postalCode}', '${country}')`);

      // TODO: O(11n) algorithm - Refactor to Stream processing, erase Array allocations, splice method
      // Assign Friends to Person (Person_Person)
      let friendCount = faker.number.int({ min: 0, max: 10 });
      let friendIds = Array.from({ length: peopleCount }, (value, index) => index + 1);
      friendIds.splice(personId - 1, 1);
      for (let j = 0; j < friendCount; j++) {
          const randomIndex = faker.number.int({ min: 0, max: friendIds.length - 1 });
          const friendId = friendIds[randomIndex];

          person.friends.add(friendId);

          friendIds.splice(randomIndex, 1);
      }

      // TODO: O(11n) algorithm - Refactor to Stream processing, erase Array allocations, splice method
      // Assign Tags to Person (Person_Tags)
      let tagIds = Array.from({ length: tagCount }, (value, index) => index + 1);
      let tagCountPerPerson = faker.number.int({ min: 0, max: 10 });
      for (let j = 0; j < tagCountPerPerson; j++) {
          const randomIndex = faker.number.int({ min: 0, max: tagIds.length - 1 });
          const tagId = tagIds[randomIndex];

          // PEOPLE_OBJECTS[personId - 1].tags.add(tagId);
          // TAG_OBJECTS[tagId - 1].interestedPeople.add(personId).add(-1);
          // personTags.push(`(${personId}, ${tagId})`);

          person.tags.add(tagId);

          tagIds.splice(randomIndex, 1);
      }

      if (i < customerCount) {
          const customerId = i + 1;
          person.customerId = customerId;
      }

      if (i % logger.batchSizeToLog === 0) {
          logger.info(`Generated ${i + 1} people and ${i + 1} customers`);
      }

      yield person;
  }

  logger.info(`Generated data for ${peopleCount} people and ${customerCount} customers`);

  // const relationalData = `INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country) VALUES ${people.join(", \n")};\n` +
  //     `INSERT INTO Customer (customerId, personId) VALUES ${customers.join(", \n")};\n` +
  //     `INSERT INTO Person_Person (personId1, personId2) VALUES ${friends.join(", \n")};\n` +
  //     `INSERT INTO Person_Tags (personId, tagId) VALUES ${personTags.join(", \n")};\n`;

  // const cassandraData = PEOPLE_OBJECTS.map(p => {
  //     const person = `(${p.personId}, '${p.firstName}', '${p.lastName}', '${p.gender}', '${p.birthday}', '${p.street}', '${p.city}', '${p.postalCode}', '${p.country}', ${p.friends.size})`;
  //     return `INSERT INTO Person (personId, firstName, lastName, gender, birthday, street, city, postalCode, country, friendCount) VALUES ${person};\n`;
  // }).join("") +
  //     people.map(person => `INSERT INTO Person_By_Birthday_Indexed (personId, firstName, lastName, gender, birthday, street, city, postalCode, country) VALUES ${person};\n`).join("");
}

// Transformers

export async function cassandraTransformVendorProducts(stream: DataStream) {
    let accumulatorRef: { brandVendorsByProductId: brandVendorsByProductId, countriesByBrand: countriesByBrand };

    await stream.accumulate((acc, product: Product) => {
        const { brand, vendor: { country: vendorCountry }, productId } = product;

        // Assign Country to Brand
        if (!acc.countriesByBrand.hasOwnProperty(brand)) {
            acc.countriesByBrand[brand] = new Set();
        }
        acc.countriesByBrand[brand].add(vendorCountry);

        acc.brandVendorsByProductId[productId] = { brand, vendorCountry };
    }, accumulatorRef = { brandVendorsByProductId: {}, countriesByBrand: {} });

    return accumulatorRef;
}