// 3.1 Non-Indexed Node/Relationship Labels

// DROP lookup indexes for this query
DROP INDEX node_label_lookup_index IF EXISTS;

DROP INDEX rel_type_lookup_index IF EXISTS;

// Match all Orders and Vendors sharing the same Contact Type
PROFILE
MATCH (o:Order)-[oc:CONTACT_TYPE]->(t)-[vc:CONTACT_TYPE]->(v:Vendor)
RETURN DISTINCT *;

// Restore the lookup indexes
CREATE LOOKUP INDEX node_label_lookup_index IF NOT EXISTS FOR (n) ON EACH labels(n);

CREATE LOOKUP INDEX rel_type_lookup_index IF NOT EXISTS FOR () - [r] - () ON EACH type(r);
