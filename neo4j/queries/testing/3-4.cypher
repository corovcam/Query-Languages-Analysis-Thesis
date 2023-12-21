// 3.4 Complex Join 2 (having more than 1 friend)

PROFILE
MATCH (p1:Person)-[:KNOWS]->(p2:Person)
WITH p1, count(p2) AS friendCount
  WHERE friendCount > 1
RETURN properties(p1), friendCount;