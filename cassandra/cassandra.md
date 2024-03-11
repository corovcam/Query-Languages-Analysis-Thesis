## Cassandra Notes
- Data modeling:
  - Query driven
  - Denormalization - duplicate data to avoid joins
  - https://cassandra.apache.org/doc/latest/cassandra/data_modeling/data_modeling_schema.html

### Data Types
- Collections - List, Set, Map
  - https://cassandra.apache.org/doc/latest/cassandra/cql/types.html#noteworthy-characteristics
    - Individual collections are not indexed internally. Which means that even to access a single element of a collection, the while collection has to be read (and reading one is not paged internally).
    - While insertion operations on sets and maps never incur a read-before-write internally, some operations on lists do. Further, some lists operations are not idempotent by nature (see the section on lists below for details), making their retry in case of timeout problematic. It is thus advised to prefer sets over lists when possible.
- List
  - https://cassandra.apache.org/doc/latest/cassandra/cql/types.html#lists
  - In general, if you can use a set instead of list, always prefer a set.
  - The append and prepend operations are not idempotent by nature. So in particular, if one of these operation timeout, then retrying the operation is not safe and it may (or may not) lead to appending/prepending the value twice.
- UDT
  - https://cassandra.apache.org/doc/latest/cassandra/cql/types.html#udts
  - UDT literal is like a map` literal but its keys are the names of the fields of the type


### Data Definition Language (DDL)
- https://cassandra.apache.org/doc/latest/cassandra/cql/ddl.html#static-column
  - Static columns are useful for denormalization. They are stored only once per partition and are shared among all rows of that partition. Static columns are not part of the primary key.


### Data Manipulation Language (DML)
- https://cassandra.apache.org/doc/latest/cassandra/cql/dml.html#allow-filtering
  - The ALLOW FILTERING option allows you to explicitly allow queries that require filtering. Please note that a query using ALLOW FILTERING may thus have unpredictable performance (for the definition of “unpredictable” here, see the section on “The WHERE clause and performance” above). In particular, it may be very slow even if the amount of data returned is very small (and it may even time out if it has to process too much data). So don’t use ALLOW FILTERING unless you know what you are doing and you also know that the amount of data returned will be very small (as in, one or two rows at most).
- https://cassandra.apache.org/doc/latest/cassandra/cql/dml.html#insert-statement
  - Unlike in SQL, INSERT does not check the prior existence of the row by default. The row is created if none existed before, and updated otherwise.
- https://cassandra.apache.org/doc/latest/cassandra/cql/dml.html#batch_statement
  - Batches are not a full analogue for SQL transactions.


### Schema

Instance ▸ keyspaces ▸ tables ▸ rows ▸columns
▸ Keyspace
▸ Table (column family)
  ▸ Collection of (similar) rows
  ▸ Table schema must be specified, yet can be modified later on
▸ Row
  ▸ Collection of columns
  ▸ Rows in a table do not need to have the same columns
  ▸ Each row is uniquely identified by a primary key
▸ Column
  ▸ Name-value pair + additional data


### Additional Notes
- https://thenewstack.io/an-apache-cassandra-breakthrough-acid-transactions-at-scale/
  - ACID transactions in Cassandra
- https://foundev.medium.com/cassandra-batch-loading-without-the-batch-keyword-40f00e35e23e
  - Import for batch loading - inneficient for large data sets
- https://docs.datastax.com/en/cql-oss/3.3/cql/cql_reference/refLimits.html
  - Limits

#### Measuring performance
- tracing on;
  - select * from system_traces.sessions; - see all tracing sessions and their "source_elapsed" time in microseconds
- Setting request timeout (read_request_timeout, range_request_timeout, request_timeout) to 5 minutes:
  - https://docs.datastax.com/en/dse/5.1/docs/managing/configure/configure-cassandra-yaml.html
  - Mounted as config volume in docker-compose.yml