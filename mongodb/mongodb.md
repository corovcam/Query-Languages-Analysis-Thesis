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
- cursor timeout
    - db.adminCommand( { setParameter: 1, cursorTimeoutMillis: 300000 } )
    - https://www.mongodb.com/docs/upcoming/reference/parameters/#mongodb-parameter-param.cursorTimeoutMillis

#### Limits
- https://www.mongodb.com/docs/manual/reference/limits/#bson-documents
    - BSON documents can have a maximum size of 16 megabytes
    - BSON documents can have a maximum of 100 levels of nesting
    - Query 3.1 hit the !BSONObj size not supported! error with `BSONObj size: 16806194 (0x1007132) is invalid. Size must be between 0 and 16793600(16MB)`
        - Solution could be not to embed both arrays in the same document, but to split them into separate documents and use $lookup to join them in the query
            ```javascript
            db.types.aggregate([
            {
                $lookup: {
                from: "orders",
                localField: "_id",
                foreignField: "contacts.typeId",
                as: "orderContacts"
                }
            },
            {
                $lookup: {
                from: "vendors",
                localField: "_id",
                foreignField: "contacts.typeId",
                as: "vendorContacts"
                }
            },
            {
                $unwind: "$orderContacts"
            },
            {
                $unwind: "$vendorContacts"
            },
            {
                $project: {
                orderContact: {
                    orderId: "$orderContacts.orderId",
                    value: "$orderContacts.value",
                },
                vendorContact: {
                    vendorId: "$vendorContacts.vendorId",
                    value: "$vendorContacts.value",
                },
                }
            }
            ]);
            ```
            - TESTED! doesn't work, still hits the same error
            ```
            PlanExecutor error during aggregation :: caused by :: Used too much memory for a single array. Memory limit: 104857600 bytes. The array contains 186021 elements and is of size 104857151 bytes. The element being added has size 574 bytes.
            at Connection.onMessage (C:\Users\marti\AppData\Local\MongoDBCompass\app-1.42.0\resources\app.asar.unpacked\node_modules\@mongosh\node-runtime-worker-thread\dist\worker-runtime.js:2:964240)
            at MessageStream.<anonymous> (C:\Users\marti\AppData\Local\MongoDBCompass\app-1.42.0\resources\app.asar.unpacked\node_modules\@mongosh\node-runtime-worker-thread\dist\worker-runtime.js:2:962195)
            at MessageStream.emit (node:events:517:28)
            at p (C:\Users\marti\AppData\Local\MongoDBCompass\app-1.42.0\resources\app.asar.unpacked\node_modules\@mongosh\node-runtime-worker-thread\dist\worker-runtime.js:2:994433)
            at MessageStream._write (C:\Users\marti\AppData\Local\MongoDBCompass\app-1.42.0\resources\app.asar.unpacked\node_modules\@mongosh\node-runtime-worker-thread\dist\worker-runtime.js:2:993123)
            at writeOrBuffer (node:internal/streams/writable:392:12)
            at _write (node:internal/streams/writable:333:10)
            at Writable.write (node:internal/streams/writable:337:10)
            at Socket.ondata (node:internal/streams/readable:777:22)
            at Socket.emit (node:events:517:28)
            at addChunk (node:internal/streams/readable:335:12)
            at readableAddChunk (node:internal/streams/readable:308:9)
            at Readable.push (node:internal/streams/readable:245:10)
            at TCP.onStreamRead (node:internal/stream_base_commons:190:23)
            ```
- Query 3.3. - enormous waiting time for MongoDB Relational Migrator to migrate orders.containsProducts array
    - Waiting time: almost 74 hours with 4 retries and various errors
    - `java.io.EOFException: Can not read response from server. Expected to read 4 bytes, read 0 bytes before connection was unexpectedly lost.`
    - `java.net.SocketTimeoutException: Read timed out`
    - https://stackoverflow.com/questions/13950496/what-is-java-io-eofexception-message-can-not-read-response-from-server-expect
    - problem turned out to be in MySQL halting the connection unexpectedly
    - solution: remove orders.containsProducts array
- Query 8.2 Without Lookup
    - 


### Stats
- 1k:
    - ETL time: 11sec
    - DB sizes with `db.stats({scale: 1024});`
```
{
  db: 'ecommerce',
  collections: Long('6'),
  views: Long('0'),
  objects: Long('5581'),
  avgObjSize: 694.7246013259272,
  dataSize: 3786.384765625,
  storageSize: 1664,
  indexes: Long('8'),
  indexSize: 204,
  totalSize: 1868,
  scaleFactor: Long('1024'),
  fsUsedSize: 70656652,
  fsTotalSize: 80446960,
  ok: 1
}
```
- 4k:
    - ETL time: 60sec
    - DB sizes with `db.stats({scale: 1024});`
```
{
  db: 'ecommerce',
  collections: Long('6'),
  views: Long('0'),
  objects: Long('20110'),
  avgObjSize: 607.0190949776231,
  dataSize: 11921.048828125,
  storageSize: 7024,
  indexes: Long('8'),
  indexSize: 444,
  totalSize: 7468,
  scaleFactor: Long('1024'),
  fsUsedSize: 70735860,
  fsTotalSize: 80446960,
  ok: 1
}
```
- 128k:
    - ETL time: 5min
    - DB sizes with `db.stats({scale: 1024});`
```
{
  db: 'ecommerce',
  collections: Long('6'),
  views: Long('0'),
  objects: Long('692332'),
  avgObjSize: 432.0068262047688,
  dataSize: 292082.177734375,
  storageSize: 203732,
  indexes: Long('10'),
  indexSize: 17332,
  totalSize: 221064,
  scaleFactor: Long('1024'),
  fsUsedSize: 70432932,
  fsTotalSize: 80446960,
  ok: 1
}
```
- 256k:
    - ETL time: 10min
    - DB sizes with `db.stats({scale: 1024});`
```
{
  db: 'ecommerce',
  collections: Long('6'),
  views: Long('0'),
  objects: Long('1365378'),
  avgObjSize: 428.21240125445115,
  dataSize: 570968.546875,
  storageSize: 261276,
  indexes: Long('11'),
  indexSize: 31064,
  totalSize: 292340,
  scaleFactor: Long('1024'),
  fsUsedSize: 78891432,
  fsTotalSize: 80446960,
  ok: 1
}
```
```
ecommerce.types | size: 423 
(0.00 GB) | storageSize: 20480 
(0.00 GB)
ecommerce.products | size: 84124154 
(0.08 GB) | storageSize: 33284096 
(0.03 GB)
ecommerce.persons | size: 69921320 
(0.07 GB) | storageSize: 38309888 
(0.04 GB)
ecommerce.tags | size: 40206394 
(0.04 GB) | storageSize: 27447296 
(0.03 GB)
ecommerce.orders | size: 189349097 
(0.18 GB) | storageSize: 74444800 
(0.07 GB)
ecommerce.vendors | size: 201070404 
(0.19 GB) | storageSize: 94040064 
(0.09 GB)
```
- 512k:
    - ETL time: 25min
    - DB sizes with `db.stats({scale: 1024});`
```
{
  db: 'ecommerce',
  collections: Long('6'),
  views: Long('0'),
  objects: Long('2790480'),
  avgObjSize: 372.3840514893495,
  dataSize: 1014775.6328125,
  storageSize: 812232,
  indexes: Long('11'),
  indexSize: 69152,
  totalSize: 881384,
  scaleFactor: Long('1024'),
  fsUsedSize: 65666108,
  fsTotalSize: 80446960,
  ok: 1
}
```