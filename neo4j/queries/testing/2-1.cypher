// 2. Aggregation

// 2.1 COUNT

PROFILE
MATCH (p:Product)
RETURN p.brand, COUNT(*) AS productCount;