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

## Testing
- Caches:
  - https://neo4j.com/docs/cypher-manual/current/query-caches/
    - query caches
    - are not used by default - check db.clearQueryCaches() - outputs -1
  - page caches - cannot start the instance with NEO4J_server_memory_pagecache_size set to 0
- Execution time in PROFILE is in ms


## Stats
- 256k:
  - DB Size: 923MB (via `du -hc /var/lib/neo4j/data/databases/neo4j/*store.db*`)
  ```
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.labeltokenstore.db
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.labeltokenstore.db.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.labeltokenstore.db.names
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.labeltokenstore.db.names.id
  26M	/var/lib/neo4j/data/databases/neo4j/neostore.nodestore.db
  52K	/var/lib/neo4j/data/databases/neo4j/neostore.nodestore.db.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.nodestore.db.labels
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.nodestore.db.labels.id
  289M	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.arrays
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.arrays.id
  52K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.index
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.index.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.index.keys
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.index.keys.id
  321M	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.strings
  52K	/var/lib/neo4j/data/databases/neo4j/neostore.propertystore.db.strings.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.relationshipgroupstore.db
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.relationshipgroupstore.db.id
  289M	/var/lib/neo4j/data/databases/neo4j/neostore.relationshipstore.db
  52K	/var/lib/neo4j/data/databases/neo4j/neostore.relationshipstore.db.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.relationshiptypestore.db
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.relationshiptypestore.db.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.relationshiptypestore.db.names
  40K	/var/lib/neo4j/data/databases/neo4j/neostore.relationshiptypestore.db.names.id
  8.0K	/var/lib/neo4j/data/databases/neo4j/neostore.schemastore.db
  52K	/var/lib/neo4j/data/databases/neo4j/neostore.schemastore.db.id
  923M	total
  ```