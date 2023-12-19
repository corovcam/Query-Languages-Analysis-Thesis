// 3.3 Complex Join 1

// Match all important information about Orders, Customers, People, Products and Vendors
PROFILE
MATCH (o:Order)-[:ORDERED_BY]->(c:Customer)-[:IS_PERSON]->(p:Person),
      (o)-[:CONTAINS_PRODUCTS]->(pr:Product),
      (pr)-[:MANUFACTURED_BY]->(v:Vendor)
RETURN properties(o), properties(c), properties(p), properties(pr), properties(v);