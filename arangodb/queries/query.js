const { db, aql } = require("@arangodb");

// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Selection

db._query(aql`
  FOR v IN vendors
  FILTER v.name == 'Vendor A'
  RETURN { vendorId: v.vendorId, name: v.name }
`);

// 1.2 Non-Indexed Selection - Range Query

db._query(aql`
  FOR p IN persons
    FILTER DATE_TIMESTAMP(p.birthday) >= DATE_TIMESTAMP('1980-01-01') && DATE_TIMESTAMP(p.birthday) <= DATE_TIMESTAMP('1990-12-31')
    RETURN { personId: p.personId, firstName: p.firstName, lastName: p.lastName, birthday: p.birthday }
`);

// 1.3 Indexed Columns

db._query(aql`
  FOR n IN vendors
    FILTER n.vendorId == 1
    RETURN { vendorId: n.vendorId, name: n.name }
`);

// 1.4 Indexed Columns - Range Query

// TODO: Index p.birthday

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

// 3.1 Non-Indexed Node/Relationship Labels

// Match all Orders and Vendors sharing the same Contact Type
db._query(aql`
  FOR o IN orders
    FOR t IN OUTBOUND o contactType
      FOR v IN OUTBOUND t contactType
        RETURN DISTINCT { order: o, vendor: v }
`);

// 3.2 Indexed Node/Relationship Labels

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

// Find all direct and indirect relationships between people limited to 3 hops

db._query(aql`
FOR p1 IN persons
  FOR p2 IN 0..3 ANY p1 knows
    RETURN DISTINCT { person1: p1, person2: p2 }
`);

// Find the shortest path between two persons

db._query(aql`
  FOR p1 IN persons
    FILTER p1.personId == 1
    FOR p2 IN persons
      FILTER p2.personId == 10
      FOR v, e IN OUTBOUND SHORTEST_PATH p1 TO p2 knows
        RETURN v
`);

// 5. Optional Traversal

// Get a list of all people and their friend count (0 if they have no friends)

db._query(aql`
FOR p1 IN persons
LET friendCount = (
  FOR p2 IN 0..1 OUTBOUND p1 knows
  FILTER p1._key == p2._key

//OPTIONS { uniqueVertices: "global", order: "bfs" }
  COLLECT originalPerson = p1 WITH COUNT INTO friendCount
  RETURN { person: originalPerson, friendCount: friendCount }
`);

// // 1. Selection, Projection, Source (of data)

// // 1.1 Non-Indexed Selection

// MATCH (v:Vendor)
//   WHERE v.name = 'Vendor 1'
// RETURN v.vendorId, v.name;

// // 1.2 Non-Indexed Selection - Range Query

// DROP INDEX idx_person_birthday IF EXISTS;

// MATCH (p:Person)
//   WHERE p.birthday >= date('1980-01-01') AND p.birthday <= date('1990-12-31')
// RETURN p.personId, p.firstName, p.lastName, p.birthday;

// // 1.3 Indexed Columns

// MATCH (n:Vendor)
//   WHERE n.vendorId = 1
// RETURN n.vendorId, n.name;

// // 1.4 Indexed Columns - Range Query

// CREATE INDEX idx_person_birthday FOR (p:Person) ON (p.birthday);

// MATCH (p:Person)
//   WHERE p.birthday >= date('1980-01-01') AND p.birthday <= date('1990-12-31')
// RETURN p.personId, p.firstName, p.lastName, p.birthday;

// // 2. Aggregation

// // 2.1 COUNT

// MATCH (p:Product)
// RETURN p.brand, COUNT(*) AS productCount;

// // 2.2 MAX

// MATCH (p:Product)
// RETURN p.brand, max(p.price) AS maxPrice;

// // 3. Join

// // 3.1 Non-Indexed Node/Relationship Labels

// // DROP lookup indexes for this query
// DROP INDEX node_label_lookup_index;

// DROP INDEX rel_type_lookup_index;

// // Match all Orders and Vendors sharing the same Contact Type
// MATCH (o:Order)-[:CONTACT_TYPE]->(t)-[:CONTACT_TYPE]->(v:Vendor)
// RETURN o, v;

// // TODO: Need to add a new Property to Order and Vendor (or CONTACT_TYPE rel) to include contact value!!!
// // TODO: Is this the same Query as the one below in SQL? What should I return??
// // Compared to SQL Query, this one JOINs based on common :CONTACT_TYPE relationships - different data model, check Schema
// //-- Join Vendor_Contacts and Order_Contacts on the type of contact (non-indexed column)
// //SELECT *
// //FROM Order_Contacts OC
// //         INNER JOIN Vendor_Contacts VC on VC.typeId = OC.typeId;

// // 3.2 Indexed Node/Relationship Labels

// // CREATE lookup indexes for this query
// CREATE LOOKUP INDEX node_label_lookup_index FOR (n) ON EACH labels(n);

// CREATE LOOKUP INDEX rel_type_lookup_index FOR () - [r] - () ON EACH type(r);

// // Match all Products contained in Orders
// MATCH (o:Order)-[cp:CONTAINS_PRODUCTS]->(p:Product)
// RETURN properties(p), o.orderId, cp.quantity;

// // TODO: Should I RETURN properties(p) or p (as whole Node)? What's the difference in Query performance?

// // 3.3 Complex Join 1

// // Match all important information about Orders, Customers, People, Products and Vendors
// MATCH (o:Order)-[:ORDERED_BY]->(c:Customer)-[:IS_PERSON]->(p:Person),
//       (o)-[:CONTAINS_PRODUCTS]->(pr:Product),
//       (pr)-[:MANUFACTURED_BY]->(v:Vendor)
// RETURN properties(o), properties(c), properties(p), properties(pr), properties(v);

// // 3.4 Complex Join 2 (having more than 1 friend)

// MATCH (p1:Person)-[:KNOWS]->(p2:Person)
// WITH p1, count(p2) AS friendCount
//   WHERE friendCount > 1
// RETURN properties(p1), friendCount;

// // 4. Unlimited Traversal (in Neo4j everything is matched by default)

// // Find all direct and indirect relationships between people limited to 3 hops
// MATCH (p1:Person)-[*..3]-(p2:Person)
// RETURN *;

// // Find the shortest path between two persons using WITH RECURSIVE
// MATCH (p1:Person {personId: 1}), (p2:Person {personId: 10}),
//       path = shortestPath((p1)-[:KNOWS*]->(p2))
// RETURN path;

// // 5. Optional Traversal

// // Get a list of all people and their friend count (0 if they have no friends)
// MATCH (p1:Person)
// OPTIONAL MATCH (p1)-[:KNOWS]->(p2:Person)
// RETURN properties(p1), count(p2) AS friendCount;

// // 6. Union

// //-- Get a list of contacts (email and phone) for both vendors and customers
// MATCH (v:Vendor)<-[:CONTACT_TYPE]-(t)
// RETURN 'Vendor' AS entityType, v.vendorId AS entityId, v.name AS entityName, t.value AS contactType
// UNION
// MATCH (p:Person)<-[:IS_PERSON]-(c:Customer)<-[:ORDERED_BY]-(o:Order)-[:CONTACT_TYPE]->(t)
// RETURN
//   'Order' AS entityType, o.orderId AS entityId, p.firstName + ' ' + p.lastName AS entityName, t.value AS contactType;

// // 7. Intersection

// - - Find common tags between posts AND persons

// MATCH (p:Post)-[:HAS_TAG]->(t:Tag)
// WITH collect(properties(t)) AS postTags
// MATCH (p:Person)-[:HAS_INTEREST]->(t:Tag)
// WITH postTags, collect(properties(t)) AS personTags
// RETURN apoc.coll.intersection(postTags, personTags) AS commonTags;

// // 8. Difference

// // Find people who have not made any orders
// MATCH (p:Person)
//   WHERE NOT (p)<-[:IS_PERSON]-(:Customer)<-[:ORDERED_BY]-(:Order)
// RETURN p.personId, p.firstName, p.lastName;

// // 9. Sorting

// // 9.1 Non-Indexed property

// MATCH (pr:Product)
// RETURN pr.brand
//   ORDER BY pr.brand;

// // 9.2 Indexed property

// CREATE INDEX idx_product_productId FOR (p:Product) ON (p.productId);

// MATCH (pr:Product)
// RETURN pr.productId
//   ORDER BY pr.productId;

// // 10. Distinct

// // Find unique combinations of product brands and the countries of the vendors selling those products

// MATCH (pr:Product)<-[:CONTAINS_PRODUCTS]-(o:Order)-[:ORDERED_BY]->(c:Customer)-[:IS_PERSON]->(p:Person),
//       (pr)-[:MANUFACTURED_BY]->(v:Vendor)
// RETURN DISTINCT pr.brand, v.country
//   ORDER BY pr.brand, v.country;

// // 11. MapReduce (not supported in Neo4j, simple aggregation instead)

// MATCH (c:Customer)<-[:ORDERED_BY]-(o:Order)
// RETURN c.customerId, count(o) AS orderCount;


