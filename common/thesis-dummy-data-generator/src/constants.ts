export const STRING_MAX_ALLOWED_LENGTH = 65535;  // 64KB
export const ARRAY_MAX_ALLOWED_LENGTH = 1024;  // 1024 elements
export const fileNames = { // File names for the generated data
    // Entities
    vendors: 'vendors',
    products: 'products',
    people: 'people',
    orders: 'orders',
    tags: 'tags',
    types: 'types',
    // Relationships
    vendorProducts: 'vendor_products',
    industries: 'industries',
    vendorContacts: 'vendor_contacts',
    customer: 'customer',
    personPerson: 'person_person',
    personTags: 'person_tags',
    orderContacts: 'order_contacts',
    orderProducts: 'order_products',
    post: 'post',
    postTags: 'post_tags'
};
export const MAX_VENDOR_PRODUCTS = 20; // Each vendor can have at most 20 products