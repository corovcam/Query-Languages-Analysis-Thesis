// 4.2 Find the shortest path between two persons
PROFILE
MATCH (p1:Person {personId: 774}), (p2:Person {personId: 12}),
      path = shortestPath((p1)-[:KNOWS*]->(p2))
RETURN path;