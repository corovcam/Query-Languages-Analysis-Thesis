// 3.1 Non-Indexed Node/Relationship Labels

// DROP lookup indexes for this query
DROP INDEX node_label_lookup_index IF EXISTS;

DROP INDEX rel_type_lookup_index IF EXISTS;

// Match all Orders and Vendors sharing the same Contact Type
PROFILE
MATCH (o:Order)-[:CONTACT_TYPE]->(t)-[:CONTACT_TYPE]->(v:Vendor)
RETURN DISTINCT o, v;