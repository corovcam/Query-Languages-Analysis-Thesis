## ArangoDB Notes

### Installation
1. Run export script from Neo4j
2. Run transform script
3. Copy to dir .data
4. Run init.sh script

### Notes
- enforce schema using JSON Schema
  - https://docs.arangodb.com/stable/concepts/data-structure/documents/schema-validation/
- limitations:
  - https://docs.arangodb.com/stable/aql/fundamentals/limitations/
- Graph traversals
  - https://arangodb.com/learn/graphs/comparing-arangodb-aql-neo4j-cypher/
- Transactions
  - https://docs.arangodb.com/3.11/develop/transactions/limitations/
- Comparison between MongoDB
  - https://arangodb.com/2012/11/comparing-arangodb-with-mongodb-and-couchdb/

### AQL
- https://docs.arangodb.com/stable/aql/data-queries/#modifying-a-single-document
  - The REPLACE operation is an alternative to the UPDATE operation that lets you replace all attributes of a document (except for attributes that cannot be changed, like _key)

### Graphs
- https://docs.arangodb.com/stable/aql/graphs/traversals/#working-with-named-graphs
    ```aql
      FOR vertex[, edge[, path]]
      IN [min[..max]]
      OUTBOUND|INBOUND|ANY startVertex
      GRAPH graphName
      [PRUNE [pruneVariable = ]pruneCondition]
      [OPTIONS options]
    ```
  - PRUNE expression (AQL expression, optional): An expression, like in a FILTER statement, which is evaluated in every step of the traversal, as early as possible.

## Testing

- measure execution time: https://docs.arangodb.com/3.11/aql/execution-and-performance/query-statistics/
- Query cache
  - https://docs.arangodb.com/3.11/aql/execution-and-performance/caching-query-results/
  - OFF by default
- Request timeout: 1200s by default (20min)
  - https://docs.arangodb.com/3.11/components/tools/arangodb-shell/options/#--serverrequest-timeout
