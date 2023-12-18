## Data
- extracted automatically from relational DBMS (MySQL) using Neo4j Labs ETL Tool graph app
  - https://neo4j.com/labs/etl-tool/
  - using `mysql_mapping.json` and neo4j-etl-cli (https://neo4j.com/labs/etl-tool/) in neo4j-etl-tool
  - need JAVA_HOME set to JDK 8 or later
- Afterwards, the data was manually cleaned up and transformed to fit the graph model
- Then apoc.export.cypher.all was used to export the data to a cypher file (specifically cypher-shell script), including unique constraints and indexes
  - https://neo4j.com/labs/apoc/4.3/overview/apoc.export/apoc.export.cypher.all/
  - CALL apoc.export.cypher.all('/neo4j/queries/data.cypher', {format:'cypher-shell'})

- Schema Visualisation: CALL db.schema.visualization();

## Notes

- Conversion of common SQL constructs to Cypher: https://neo4j.com/developer/cypher/guide-sql-to-cypher/
- INDEXES: https://neo4j.com/docs/cypher-manual/5/indexes-for-search-performance/
  - Lookup Index is automatically created for each Node and Relationship
    - Need to be dropped before testing of queries