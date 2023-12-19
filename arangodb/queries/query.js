const { db, aql } = require("@arangodb");

// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Selection

db._query(aql`
  FOR v IN vendors
  FILTER v.name == 'Bauch - Denesik'
  RETURN { vendorId: v.vendorId, name: v.name }
`);

// 1.2 Non-Indexed Selection - Range Query

try {
  db.persons.dropIndex('idx_person_birthday');
} catch (e) {
  // index does not exist
}

db._query(aql`
  FOR p IN persons
    FILTER DATE_TIMESTAMP(p.birthday) >= DATE_TIMESTAMP('1980-01-01') && DATE_TIMESTAMP(p.birthday) <= DATE_TIMESTAMP('1990-12-31')
    RETURN { personId: p.personId, firstName: p.firstName, lastName: p.lastName, birthday: p.birthday }
`);

// 1.3 Indexed Columns

db.vendors.ensureIndex(
  { type: "persistent", name: "idx_vendors_vendorID", unique: true, fields: [ "vendorId" ] }
);

db._query(aql`
  FOR n IN vendors
    FILTER n.vendorId == 24
    RETURN { vendorId: n.vendorId, name: n.name }
`);

// 1.4 Indexed Columns - Range Query

db.persons.ensureIndex(
  { type: "persistent", name: "idx_person_birthday", unique: false, fields: [ "birthday" ] }
);

db._query(aql`
  FOR p IN persons
    FILTER DATE_TIMESTAMP(p.birthday) >= DATE_TIMESTAMP('1980-01-01') && DATE_TIMESTAMP(p.birthday) <= DATE_TIMESTAMP('1990-12-31')
    RETURN { personId: p.personId, firstName: p.firstName, lastName: p.lastName, birthday: p.birthday }
`);

// 2. Aggregation

// 2.1 COUNT

db._query(aql`
  FOR pr IN products
    COLLECT brand = pr.brand WITH COUNT INTO productCount
    RETURN { brand: brand, productCount: productCount }
`);

// 2.2 MAX

db._query(aql`
  FOR pr IN products
    COLLECT brand = pr.brand
    AGGREGATE maxPrice = MAX(pr.price)
    RETURN { brand: brand, maxPrice: maxPrice }
`); 

// 3. Join

// 3.1 Non-Indexed Node/Relationship keys

// TODO: Drop indexes for this query
// Primary Indexes cannot be dropped: https://docs.arangodb.com/3.11/index-and-search/indexing/basics/#primary-index
// Need to change the query? 

// Match all Orders and Vendors sharing the same Contact Type
db._query(aql`
  FOR o IN orders
    FOR t IN OUTBOUND o contactType
      FOR v IN OUTBOUND t contactType
        RETURN DISTINCT { typeId: t, order: o, orderContact: oc, vendor: v, vendorContact: vc }
`);

// 3.2 Indexed Node/Relationship keys

// Match all Products contained in Orders
db._query(aql`
FOR o IN orders
    FOR pr, cp IN OUTBOUND o containsProducts
      RETURN { product: pr, orderId: o.orderId, quantity: cp.rel.quantity }
`);

// 3.3 Complex Join 1

// Match all important information about Orders, Customers, People, Products and Vendors
db._query(aql`
  FOR o IN orders
    FOR c IN OUTBOUND o orderedBy
      FOR p IN OUTBOUND c isPerson
    FOR pr IN OUTBOUND o containsProducts
      FOR v IN OUTBOUND pr manufacturedBy
        RETURN { order: o, customer: c, person: p, product: pr, vendor: v }
`);

// 3.4 Complex Join 2 (having more than 1 friend)

db._query(aql`
  FOR p1 IN persons
    FOR p2 IN OUTBOUND p1 knows
      COLLECT originalPerson = p1 WITH COUNT INTO friendCount
      FILTER friendCount > 1
      RETURN { person: originalPerson, friendCount: friendCount }
`);

// 4. Unlimited Traversal

// 4.1 Find all direct and indirect relationships between people limited to 3 hops

db._query(aql`
FOR p1 IN persons
  FOR p2 IN 0..3 ANY p1 knows
    RETURN DISTINCT { person1: p1, person2: p2 }
`);

// 4.2 Find the shortest path between two persons

db._query(aql`
  FOR p1 IN persons
    FILTER p1.personId == 774
    FOR p2 IN persons
      FILTER p2.personId == 12
      FOR v, e IN OUTBOUND SHORTEST_PATH p1 TO p2 knows
        RETURN v
`);

// 5. Optional Traversal

// Get a list of all people and their friend count (0 if they have no friends)

db._query(aql`
FOR p1 IN persons
  LET friends = (
    FOR p2 IN OUTBOUND p1 knows
    RETURN 1
  )
  RETURN { person: p1, friendCount: LENGTH(friends) }
`);

// 6. Union

// Get a list of contacts (email and phone) for both vendors and customers

db._query(aql`
  LET vendorContacts = (
    FOR v IN vendors
      FOR t IN INBOUND v contactType
      RETURN { entityType: 'Vendor', entityId: v.vendorId, entityName: v.name, contactType: t.value }
  )

  LET orderContacts = (
    FOR p IN persons
      FOR c IN INBOUND p isPerson
      FOR o IN INBOUND c orderedBy
      FOR t IN OUTBOUND o contactType
      RETURN { entityType: 'Order', entityId: o.orderId, entityName: CONCAT(p.firstName, ' ', p.lastName), contactType: t.value }
  )

  RETURN UNION(vendorContacts, orderContacts)
`);

// 7. Intersection

// Find common tags between posts AND persons

db._query(aql`
  LET postTags = (
    FOR p IN posts
      FOR t IN OUTBOUND p hasTag
      RETURN { tagId: t.tagId, value: t.value }
  )

  LET personTags = (
    FOR p IN persons
      FOR t IN OUTBOUND p hasInterest
      RETURN { tagId: t.tagId, value: t.value }
  )

  RETURN INTERSECTION(postTags, personTags)
`);

// 8. Difference

// Find people who have not made any orders

db._query(aql`
  FOR p IN persons
    FILTER LENGTH(
      FOR c IN INBOUND p isPerson
        FOR o IN INBOUND c orderedBy
          RETURN 1
    ) == 0
    RETURN p
`);

// 9. Sorting

// 9.1 Non-Indexed property

db._query(aql`
  FOR pr IN products
    SORT pr.brand
    RETURN pr.brand
`);

// 9.2 Indexed property

// _key is the default primary index for all collections

db._query(aql`
  FOR pr IN products
    SORT pr._key
    RETURN pr._key
`);

// 10. Distinct

// Find unique combinations of product brands and the countries of the vendors selling those products

db._query(aql`
  FOR pr IN products
    FOR v IN OUTBOUND pr manufacturedBy
      //COLLECT brand = pr.brand, country = v.country
      SORT pr.brand, v.country
      RETURN DISTINCT { brand: pr.brand, country: v.country }
`);

// 11. MapReduce (not supported in ArangoDB, simple aggregation instead)

// Find the number of orders per customer

db._query(aql`
  FOR c IN customers
    FOR o IN INBOUND c orderedBy
      COLLECT customerId = c.customerId WITH COUNT INTO orderCount
      RETURN { customerId: customerId, orderCount: orderCount }
`);
