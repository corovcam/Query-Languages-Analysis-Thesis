## Data
- extracted automatically from relational DBMS (MySQL) using Neo4j Labs ETL Tool graph app
  - https://neo4j.com/labs/etl-tool/
- Afterwards, the data was manually cleaned up and transformed to fit the graph model
- Then apoc.export.cypher.all was used to export the data to a cypher file (specifically cypher-shell script), including unique constraints and indexes
  - https://neo4j.com/labs/apoc/4.3/overview/apoc.export/apoc.export.cypher.all/
  - CALL apoc.export.cypher.all('/neo4j/queries/data.cypher', {format:'cypher-shell'})