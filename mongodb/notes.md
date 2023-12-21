## MongoDB Notes

- https://www.diva-portal.org/smash/get/diva2:1278762/FULLTEXT01.pdf
  - MongoDB vs. MySQL

### General

- limitations
    - https://www.mongodb.com/docs/manual/core/document/#document-limitations

- SQL comparison
    - full comparison of query languages, data types, and operators
    - https://www.mongodb.com/docs/manual/reference/sql-comparison/

- ArangoDB comparison   
    - https://arangodb.com/tutorials/mongodb-to-arangodb-tutorial/

- RelationalMigrator
    - https://www.mongodb.com/docs/relational-migrator/

### Notes

- https://www.mongodb.com/docs/manual/tutorial/insert-documents/#atomicity
  - MongoDB provides atomic operations on single documents.
- https://www.mongodb.com/docs/manual/tutorial/query-embedded-documents/#match-an-embedded-nested-document
  
#### Schema
Instance ▸ database ▸ collections ▸ documents
▸ Database
▸ Collection
    ▸ Collection of documents, usually of a similar structure
▸ Document
    ▸ MongoDB document = one JSON object
    ▸ i.e. even a complex JSON object with other recursively nested objects, arrays or values
    ▸ Unique immutable identifier _id
    ▸ Field name restrictions: _id, $, .

#### Queries
- document identifiers are immutable
  - can't update _id attributes of documents

#### Indexes
- Full collection scan must be conducted when searching for documents unless an appropriate index exists
- PRIMARY INDEX
    ▸ Unique index on values of the _id field
    ▸ Created automatically
- SECONDARY INDEXES
    ▸ Created manually for values of a given key field / fields
    ▸ Always within just a single collection


#### Aggregation

- Excessive use of $lookup within a query may slow down performance. To avoid multiple $lookup stages, consider an embedded data model to optimize query performance.

### Testing

- https://stackoverflow.com/questions/9362831/how-can-i-check-mongodb-query-performance-without-cache
    - query cache