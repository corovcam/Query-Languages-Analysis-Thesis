// Nodes

CALL apoc.export.json.query(
    "MATCH (vendor:Vendor) RETURN vendor;",
    "exports/nodes/vendors.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH (product:Product) RETURN product;",
    "exports/nodes/products.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH (order:Order) RETURN order;",
    "exports/nodes/orders.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH (type:Type) RETURN type;",
    "exports/nodes/types.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH (customer:Customer) RETURN customer;",
    "exports/nodes/customers.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH (person:Person) RETURN person;",
    "exports/nodes/persons.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH (post:Post) RETURN post;",
    "exports/nodes/posts.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH (tag:Tag) RETURN tag;",
    "exports/nodes/tags.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

// Relationships

CALL apoc.export.json.query(
    "MATCH ()-[contact_type:CONTACT_TYPE]->() RETURN *;",
    "exports/edges/contactType.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[contains_products:CONTAINS_PRODUCTS]->() RETURN *;",
    "exports/edges/containsProducts.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[created_by:CREATED_BY]->() RETURN *;",
    "exports/edges/createdBy.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[has_interest:HAS_INTEREST]->() RETURN *;",
    "exports/edges/hasInterest.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[has_tag:HAS_TAG]->() RETURN *;",
    "exports/edges/hasTag.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[industry_type:INDUSTRY_TYPE]->() RETURN *;",
    "exports/edges/industryType.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[is_person:IS_PERSON]->() RETURN *;",
    "exports/edges/isPerson.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[knows:KNOWS]->() RETURN *;",
    "exports/edges/knows.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[manufactured_by:MANUFACTURED_BY]->() RETURN *;",
    "exports/edges/manufacturedBy.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);

CALL apoc.export.json.query(
    "MATCH ()-[ordered_by:ORDERED_BY]->() RETURN *;",
    "exports/edges/orderedBy.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
);