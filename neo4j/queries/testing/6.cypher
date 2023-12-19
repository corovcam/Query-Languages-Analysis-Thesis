// 6. Union

// Get a list of contacts (email and phone) for both vendors and customers
PROFILE
MATCH (v:Vendor)<-[:CONTACT_TYPE]-(t)
RETURN 'Vendor' AS entityType, v.vendorId AS entityId, v.name AS entityName, t.value AS contactType
UNION
MATCH (p:Person)<-[:IS_PERSON]-(c:Customer)<-[:ORDERED_BY]-(o:Order)-[:CONTACT_TYPE]->(t)
RETURN
  'Order' AS entityType, o.orderId AS entityId, p.firstName + ' ' + p.lastName AS entityName, t.value AS contactType;