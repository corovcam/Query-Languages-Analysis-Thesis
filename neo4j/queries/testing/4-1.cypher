// 4.1 Find all direct and indirect relationships between people limited to 4 hops
PROFILE
MATCH (p1:Person)-[:KNOWS*..4]->(p2:Person)
RETURN DISTINCT *;