// 5. Optional Traversal

// Get a list of all people and their friend count (0 if they have no friends)
PROFILE
MATCH (p1:Person)
OPTIONAL MATCH (p1)-[:KNOWS]->(p2:Person)
RETURN properties(p1), count(p2) AS friendCount;