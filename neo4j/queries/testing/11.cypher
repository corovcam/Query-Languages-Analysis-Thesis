// 11. MapReduce (not supported in Neo4j, simple aggregation instead)

PROFILE
MATCH (c:Customer)<-[:ORDERED_BY]-(o:Order)
RETURN c.customerId, count(o) AS orderCount;