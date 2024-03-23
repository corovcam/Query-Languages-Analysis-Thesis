LOAD CSV FROM 'file:///posts.tsv' AS row FIELDTERMINATOR '\t'
CALL {
 WITH row
 CREATE (p:Post {postId:row[0], imageFile:row[2], creationDate:row[3], locationIp:row[4], browserUsed:row[5], language:row[6], content:row[7], length:row[8]})
} IN TRANSACTIONS OF 10000 ROWS;

// LOAD CSV FROM 'file:///posts.tsv' AS row FIELDTERMINATOR '\t'
// CALL {
//  WITH row
//  RETURN apoc.create.vnode(["Post"], {postId:row[0], imageFile:row[2], creationDate:row[3], locationIp:row[4], browserUsed:row[5], language:row[6], content:row[7], length:row[8]})
//  LIMIT 10
// } IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV FROM 'file:///posts_tags.tsv' AS row FIELDTERMINATOR '\t'
CALL {
  WITH row
  MATCH (p:Post { postId: row[0] })
  MATCH (t:Tag { tagId: row[1] })
  CREATE (p)-[:HAS_TAG]->(t)
} IN TRANSACTIONS OF 10000 ROWS;

// LOAD CSV FROM 'file:///posts_tags.tsv' AS row FIELDTERMINATOR '\t'
// WITH row
// MATCH (t:Tag { tagId: row[1] })
// MATCH (p:Post { postId: row[0] })
// RETURN apoc.create.vRelationship(p, 'HAS_TAG', null, t)
// LIMIT 10;

