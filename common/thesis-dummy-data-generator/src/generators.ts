import { CustomLogger as logger, CustomFaker, capitalizeFirstLetter } from './utils';
import { MAX_VENDOR_PRODUCTS } from './constants';
import { Vendor, Product, Person, Order, Tag, Type, ContactType, IndustryType, Post } from './types';

const faker = CustomFaker.faker;

export function generateTypeMapping(industryCount = 10, contactTypes = ["Email", "Phone", "Address"]) {
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

export function* generateVendorsProducts(vendorCount = 100, productCount = 1000, industryTypes: IndustryType[], contactTypes: ContactType[]): Generator<Vendor> {
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

      for (const product of generateProductsForVendor(vendor, productsPerVendor, productsAssigned)) {
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

function* generateProductsForVendor(vendor: Vendor, productsPerVendor: number, productsAssigned: number): Generator<Product> {
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

export function* generatePeople(peopleCount: number, customerCount = peopleCount, tagCount: number, tags?: Tag[]): Generator<Person> {
  logger.info(`Generating data for ${peopleCount} people and ${customerCount} customers`);

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

      const friendGenerator = (function* () {
          let friendCount = faker.number.int({ min: 0, max: 10 });
          let friendIds = Array.from({ length: peopleCount }, (value, index) => index + 1);
          friendIds.splice(personId - 1, 1);
          for (let j = 0; j < friendCount; j++) {
              const randomIndex = faker.number.int({ min: 0, max: friendIds.length - 1 });
              const friendId = friendIds[randomIndex];

              yield friendId;
              friendIds.splice(randomIndex, 1);
          }
      });

      for (const friendId of friendGenerator()) {
          person.friends.add(friendId);
      }

      const tagGenerator = (function* () {
          let tagIds = Array.from({ length: tagCount }, (value, index) => index + 1);
          let tagCountPerPerson = faker.number.int({ min: 0, max: 10 });
          for (let j = 0; j < tagCountPerPerson; j++) {
              const randomIndex = faker.number.int({ min: 0, max: tagIds.length - 1 });
              const tagId = tagIds[randomIndex];

              yield tagId;
              tagIds.splice(randomIndex, 1);
          }
      });

      for (const tagId of tagGenerator()) {
          person.tags.add(tagId);
          tags && tags[tagId - 1].interestedPeople.add(personId).add(-1);
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
}

export function* generateTags(tagCount = 100) {
  logger.info(`Generating data for ${tagCount} tags`);

  let randomTags = faker.helpers.uniqueArray(faker.lorem.word, tagCount);
  // faker.helpers.uniqueArray() can sometimes return less than the required number of unique elements
  // so we need to generate more tags to reach the required count
  randomTags.length < tagCount && randomTags.push(...faker.helpers.uniqueArray(() => faker.company.buzzNoun().replace(/'/g, "''"), tagCount - randomTags.length));
  randomTags = randomTags.length < tagCount ? randomTags.concat(Array.from({ length: tagCount - randomTags.length }, faker.string.nanoid)) : randomTags;

  for (const [i, tagValue] of randomTags.entries()) {
      const tag: Tag = { tagId: i + 1, value: tagValue };

      if (i % logger.batchSizeToLog === 0) {
          logger.info(`Generated ${i + 1} tags`);
      }

      yield tag;
  }

  logger.info(`Generated data for ${tagCount} tags`);
}

export function* generatePosts(postCount: number, peopleCount: number, tags?: Tag[]) {
  logger.info(`Generating data for ${postCount} posts`);

  for (let i = 0; i < postCount; i++) {
      const postId = i + 1;
      const personId = faker.number.int({ min: 1, max: peopleCount });
      const creationDate = faker.date.recent().toISOString().slice(0, -1);
      const language = faker.helpers.arrayElement(['English', 'Spanish', 'French', 'German', 'Chinese']);
      const postContent = postCount < 128000 ? faker.lorem.paragraphs({ min: 1, max: 5 }) : "";
      const postLength = postContent.length;

      const post: Post = {
          postId, personId, imageFile: faker.image.url(), creationDate, locationIP: faker.internet.ip(),
          browserUsed: faker.internet.userAgent(), language, content: postContent, length: postLength, tags: []
      };
      
      // Assign Tags to Post (Post_Tags)
      let tagIds = Array.from({ length: postCount }, (value, index) => index + 1);
      let tagCountPerPost = faker.number.int({ min: 0, max: 10 });
      for (let j = 0; j < tagCountPerPost; j++) {
          const randomIndex = faker.number.int({ min: 0, max: tagIds.length - 1 });
          const tagId = tagIds[randomIndex];

          tags && tags[tagId - 1].postsTagged.add(postId).add(-1);
          post.tags.push(tagId);

          tagIds.splice(randomIndex, 1);
      }

      if (i % logger.batchSizeToLog === 0) {
          logger.info(`Generated ${i + 1} posts`);
      }

      yield post;
  }

  logger.info(`Generated data for ${postCount} posts`);
}

export function* generateOrders(customerCount: number, maxOrdersPerCustomer = 3, productCount: number, contactTypes: ContactType[]) {
  logger.info(`Generating orders for ${customerCount} customers and ${maxOrdersPerCustomer} orders per customer`);

  let orderId = 1;
  for (let i = 0; i < customerCount; i++) {
      const customerId = i + 1;

      const orderCount = faker.number.int({ min: 1, max: maxOrdersPerCustomer });
      for (let j = 0; j < orderCount; j++) {
          const order: Order = { orderId, customer: { customerId }, contacts: [], products: [] };

          // Assign Contacts to Order
          // @ts-ignore
          const chosenContactTypes = faker.helpers.arrayElements(contactTypes, { min: 1 });
          chosenContactTypes.forEach(type => {
              const chosenContactValue = chooseContactValue(type.value);
              order.contacts.push({ typeId: type.typeId, value: chosenContactValue, type: { value: type.value } });
          });

          // Assign Products to Order
          let productIdArray = Array.from({ length: productCount }, (value, index) => index + 1);
          let productsPerOrder = faker.number.int({ min: 1, max: 5 });
          for (let j = 0; j < productsPerOrder; j++) {
              const randomIndex = faker.number.int({ min: 0, max: productIdArray.length - 1 });
              const productId = productIdArray[randomIndex];
              const quantity = faker.number.int({ min: 1, max: 5 });

              order.products.push({ productId, quantity });

              productIdArray.splice(randomIndex, 1);
          }

          if (i % logger.batchSizeToLog === 0) {
              logger.info(`Generated ${i + 1} orders for ${customerId}`);
          }

          yield order;

          orderId++;
      }
  }

  logger.info(`Generated data for ${orderId - 1} orders`);
}
