/** File name constant. Change this in case you wish to have different file names (not recommended). */
export const fileNames = { // File names for the generated data
    // Entities
    vendors: 'Vendor',
    products: 'Product',
    people: 'Person',
    orders: 'Order',
    tags: 'Tag',
    types: 'Type',
    post: 'Post',
    // Relationships
    vendorProducts: 'Vendor_Products',
    industries: 'Industry',
    vendorContacts: 'Vendor_Contacts',
    customer: 'Customer',
    personPerson: 'Person_Person',
    personTags: 'Person_Tags',
    orderContacts: 'Order_Contacts',
    orderProducts: 'Order_Products',
    postTags: 'Post_Tags',
};

/** Maximum number of products per vendor. */
export const MAX_VENDOR_PRODUCTS = 20; // Each vendor can have at most 20 products