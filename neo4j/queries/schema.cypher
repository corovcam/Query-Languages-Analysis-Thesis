:begin
// Delete all nodes, relationships and indices
CALL apoc.schema.assert({},{},true);
MATCH (n) DETACH DELETE n;
:commit