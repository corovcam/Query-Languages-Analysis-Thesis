// 7. Intersection

// Find common tags between posts AND persons

PROFILE
MATCH (p:Post)-[:HAS_TAG]->(t:Tag)
WITH collect(properties(t)) AS postTags
MATCH (p:Person)-[:HAS_INTEREST]->(t:Tag)
WITH postTags, collect(properties(t)) AS personTags
RETURN apoc.coll.intersection(postTags, personTags) AS commonTags;