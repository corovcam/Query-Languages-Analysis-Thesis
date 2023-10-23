MATCH (n:Vendor) RETURN n;

MATCH (n:Vendor) WHERE n.vendorId = 1 RETURN n;

MATCH (n:Vendor) WHERE n.vendorId = 1 or n.vendorId = 2 RETURN n;

MATCH (n:Vendor) WHERE n.vendorId IN [1, 2] RETURN n;
