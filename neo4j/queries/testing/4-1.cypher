// 4.1 Find all direct and indirect relationships between people limited to 3 hops
PROFILE
MATCH (p1:Person)-[:KNOWS*..3]-(p2:Person)
RETURN DISTINCT *;