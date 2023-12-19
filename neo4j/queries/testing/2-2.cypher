// 2.2 MAX

PROFILE
MATCH (p:Product)
RETURN p.brand, max(p.price) AS maxPrice;