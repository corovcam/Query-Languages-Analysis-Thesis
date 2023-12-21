// 10. Distinct

// Find unique combinations of product brands and the countries of the vendors selling those products

PROFILE
MATCH (pr:Product)-[:MANUFACTURED_BY]->(v:Vendor)
RETURN DISTINCT pr.brand, v.country
  ORDER BY pr.brand, v.country;