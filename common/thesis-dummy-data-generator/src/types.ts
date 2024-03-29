export interface Type {
  typeFor: "contact" | "industry",
  typeId: number,
  value?: string,
}

export interface ContactType extends Type {
  value: "email" | "phone" | "address",
}

export interface IndustryType extends Type {
  value: string,
}

export interface Contact {
  typeId: number,
  value: string,
  type: { value: ContactType["value"] },
}

export interface Vendor {
  vendorId: number,
  name: string,
  country: string,
  // Cassandra additional attributes
  contacts?: Contact[],
  // For future denormalization
  industries?: IndustryType[],
  products?: Product[],
}

export interface Person {
  personId: number,
  firstName: string,
  lastName: string,
  gender: "male" | "female",
  birthday: string,
  street: string,
  city: string,
  postalCode: string,
  country: string,
  // Cassandra additional attributes
  customerId?: number,
  friends?: Set<number>,
  tags?: Set<number>,
  ordersCreated?: Set<number>,
}

export interface Customer {
  customerId: number,
  // Cassandra additional attributes
  person?: Person,
}

export interface Product {
  productId: number,
  asin?: string,
  title?: string,
  price?: number | string,
  brand?: string,
  imageUrl?: string,
  // Cassandra additional attributes
  vendor?: Vendor,
  quantity?: number,
}

export interface Order {
  orderId: number,
  customer: Customer,
  // Cassandra additional attributes
  contacts?: Contact[],
  products?: Product[],
}

export interface Tag {
  tagId: number,
  value: string,
  // Cassandra additional attributes
  interestedPeople?: Set<number>,
  postsTagged?: Set<number>,
}

export interface Post {
  postId: number,
  personId: number,
  imageFile: string,
  creationDate: string,
  locationIP: string,
  browserUsed: string,
  language: string,
  content: string, // only for postCount < 128000 otherwise empty string
  length: number,
  // Cassandra additional attributes
  tags?: number[],
}

export type countriesByBrand = Record<string, Set<string>>;

export type brandVendorsByProductId = Record<number, { brand: string, vendorCountry: string }>;