CALL apoc.export.json.query(
    "MATCH (vendor:Vendor) RETURN vendor",
    "exports/vendors.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
)

CALL apoc.export.json.query(
    "MATCH (product:Product) RETURN product",
    "exports/products.json",
    {useTypes:true,writeNodeProperties:true,jsonFormat:"ARRAY_JSON"}
)

CALL apoc.export.json.query(
    "MATCH ()-[vendor_product:VENDOR_PRODUCTS]->() RETURN vendor_product",
    "exports/vendor_products.json",
    {useTypes:true,writeNodeProperties:false,jsonFormat:"ARRAY_JSON"}
)