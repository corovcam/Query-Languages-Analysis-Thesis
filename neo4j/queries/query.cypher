// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Selection

MATCH (v:Vendor)
  WHERE v.name = 'Vendor 1'
RETURN v.vendorId, v.name;

// 1.2 Non-Indexed Selection - Range Query

DROP INDEX idx_person_birthday IF EXISTS;

MATCH (p:Person)
  WHERE p.birthday >= date('1980-01-01') AND p.birthday <= date('1990-12-31')
RETURN p.personId, p.firstName, p.lastName, p.birthday;

// 1.3 Indexed Selection

MATCH (n:Vendor)
  WHERE n.vendorId = 1
RETURN n.vendorId, n.name;

// 1.4 Indexed Selection - Range Query

CREATE INDEX idx_person_birthday FOR (p:Person) ON (p.birthday);

MATCH (p:Person)
  WHERE p.birthday >= date('1980-01-01') AND p.birthday <= date('1990-12-31')
RETURN p.personId, p.firstName, p.lastName, p.birthday;

// 2. Aggregation

// 2.1 COUNT

MATCH (p:Product)
RETURN p.brand, COUNT(*) AS productCount;

// 2.2 MAX

MATCH (p:Product)
RETURN p.brand, max(p.price) AS maxPrice;

// 3. Join

// 3.1 Non-Indexed Node/Relationship Labels

// DROP lookup indexes for this query
DROP INDEX node_label_lookup_index;

DROP INDEX rel_type_lookup_index;

// Match all Orders and Vendors sharing the same Contact Type
MATCH (o:Order)-[:CONTACT_TYPE]->(t)-[:CONTACT_TYPE]->(v:Vendor)
RETURN DISTINCT o, v;

// TODO: Need to add a new Property to Order and Vendor (or CONTACT_TYPE rel) to include contact value!!!
// TODO: Is this the same Query as the one below in SQL? What should I return??
// Compared to SQL Query, this one JOINs based on common :CONTACT_TYPE relationships - different data model, check Schema
//-- Join Vendor_Contacts and Order_Contacts on the type of contact (non-indexed column)
//SELECT *
//FROM Order_Contacts OC
//         INNER JOIN Vendor_Contacts VC on VC.typeId = OC.typeId;

// 3.2 Indexed Node/Relationship Labels

// CREATE lookup indexes for this query
CREATE LOOKUP INDEX node_label_lookup_index FOR (n) ON EACH labels(n);

CREATE LOOKUP INDEX rel_type_lookup_index FOR () - [r] - () ON EACH type(r);

// Match all Products contained in Orders
MATCH (o:Order)-[cp:CONTAINS_PRODUCTS]->(p:Product)
RETURN properties(p), o.orderId, cp.quantity;

// TODO: Should I RETURN properties(p) or p (as whole Node)? What's the difference in Query performance?

// 3.3 Complex Join 1

// Match all important information about Orders, Customers, People, Products and Vendors
MATCH (o:Order)-[:ORDERED_BY]->(c:Customer)-[:IS_PERSON]->(p:Person),
      (o)-[:CONTAINS_PRODUCTS]->(pr:Product),
      (pr)-[:MANUFACTURED_BY]->(v:Vendor)
RETURN properties(o), properties(c), properties(p), properties(pr), properties(v);

// 3.4 Complex Join 2 (having more than 1 friend)

MATCH (p1:Person)-[:KNOWS]->(p2:Person)
WITH p1, count(p2) AS friendCount
  WHERE friendCount > 1
RETURN properties(p1), friendCount;

// 4. Unlimited Traversal (in Neo4j everything is matched by default)

// Find all direct and indirect relationships between people limited to 3 hops
MATCH (p1:Person)-[*..3]-(p2:Person)
RETURN DISTINCT *;

// Find the shortest path between two persons
MATCH (p1:Person {personId: 1}), (p2:Person {personId: 10}),
      path = shortestPath((p1)-[:KNOWS*]->(p2))
RETURN path;

// 5. Optional Traversal

// Get a list of all people and their friend count (0 if they have no friends)
MATCH (p1:Person)
OPTIONAL MATCH (p1)-[:KNOWS]->(p2:Person)
RETURN properties(p1), count(p2) AS friendCount;

// 6. Union

// Get a list of contacts (email and phone) for both vendors and customers
MATCH (v:Vendor)<-[:CONTACT_TYPE]-(t)
RETURN 'Vendor' AS entityType, v.vendorId AS entityId, v.name AS entityName, t.value AS contactType
UNION
MATCH (p:Person)<-[:IS_PERSON]-(c:Customer)<-[:ORDERED_BY]-(o:Order)-[:CONTACT_TYPE]->(t)
RETURN
  'Order' AS entityType, o.orderId AS entityId, p.firstName + ' ' + p.lastName AS entityName, t.value AS contactType;

// 7. Intersection

// Find common tags between posts AND persons

MATCH (p:Post)-[:HAS_TAG]->(t:Tag)
WITH collect(properties(t)) AS postTags
MATCH (p:Person)-[:HAS_INTEREST]->(t:Tag)
WITH postTags, collect(properties(t)) AS personTags
RETURN apoc.coll.intersection(postTags, personTags) AS commonTags;

// 8. Difference

// Find people who have not made any orders
MATCH (p:Person)
  WHERE NOT (p)<-[:IS_PERSON]-(:Customer)<-[:ORDERED_BY]-(:Order)
RETURN p.personId, p.firstName, p.lastName;

// 9. Sorting

// 9.1 Non-Indexed property

MATCH (pr:Product)
RETURN pr.brand
  ORDER BY pr.brand;

// 9.2 Indexed property

CREATE INDEX idx_product_productId FOR (p:Product) ON (p.productId);

MATCH (pr:Product)
RETURN pr.productId
  ORDER BY pr.productId;

// 10. Distinct

// Find unique combinations of product brands and the countries of the vendors selling those products

MATCH (pr:Product)<-[:CONTAINS_PRODUCTS]-(o:Order)-[:ORDERED_BY]->(c:Customer)-[:IS_PERSON]->(p:Person),
      (pr)-[:MANUFACTURED_BY]->(v:Vendor)
RETURN DISTINCT pr.brand, v.country
  ORDER BY pr.brand, v.country;

// 11. MapReduce (not supported in Neo4j, simple aggregation instead)

MATCH (c:Customer)<-[:ORDERED_BY]-(o:Order)
RETURN c.customerId, count(o) AS orderCount;
