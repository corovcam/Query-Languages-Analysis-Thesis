import { CustomLogger as logger, CustomFaker, capitalizeFirstLetter } from './utils';
import { STRING_MAX_ALLOWED_LENGTH, ARRAY_MAX_ALLOWED_LENGTH, MAX_VENDOR_PRODUCTS, fileNames } from './constants';
import { Vendor, Product, Person, Order, Tag, Type, ContactType, IndustryType } from './types';

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

export async function* generateVendors(vendorCount = 100, productCount = 1000, typeMapping = getTypeMapping()) {
  logger.info(`Generating data for ${vendorCount} vendors and ${productCount} products`);

  const industryTypes = typeMapping.filter(type => type.typeFor === "industry") as IndustryType[];
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

      // Update productsAssigned count
      productsAssigned += productsPerVendor;

      // Assign Industries to Vendor
      faker.helpers.arrayElements(industryTypes, { min: 1, max: 3 }).forEach(type => vendor.industries!.push(type));

      // Assign Contacts to Vendor
      const chosenContactTypes = faker.helpers.arrayElements(typeMapping.filter(type => type.typeFor === "contact")) as ContactType[];
      chosenContactTypes.forEach(type => {
          const chosenContactValue = chooseContactValue(type.value);
          const contact = { typeId: type.typeId, value: chosenContactValue, type: { value: type.value } };
          vendor.contacts!.push(contact);
      });

      yield vendor;
  }

  logger.info(`Generated data for ${vendorCount} vendors and ${productsAssigned} products`);
}

export function* generateProductsForVendor(vendor: Vendor, productCount: number): Generator<Product> {
  for (let i = 0; i < productCount; i++) {
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

    // // Assign Country to Brand
    // if (!countriesByBrand.hasOwnProperty(brand)) {
    //     countriesByBrand[brand] = new Set();
    // }
    // countriesByBrand[brand].add(vendorCountry);

    // brandVendorsByProductId[productId] = { brand, vendorCountry };
    yield product;
  }
}