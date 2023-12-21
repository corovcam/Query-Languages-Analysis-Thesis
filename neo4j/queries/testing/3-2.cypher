// 3.2 Indexed Node/Relationship Labels

// CREATE lookup indexes for this query
CREATE LOOKUP INDEX node_label_lookup_index IF NOT EXISTS FOR (n) ON EACH labels(n);

CREATE LOOKUP INDEX rel_type_lookup_index IF NOT EXISTS FOR () - [r] - () ON EACH type(r);

// Match all Products contained in Orders
PROFILE
MATCH (o:Order)-[cp:CONTAINS_PRODUCTS]->(p:Product)
RETURN properties(p), o.orderId, cp.quantity;