:begin
// Delete all nodes, relationships and indices
CALL apoc.schema.assert({},{},true);
:commit

:begin
MATCH (n) DETACH DELETE n;
:commit