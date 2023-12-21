### Create Table

- AutoIncrement is very computationally expensive, so we should avoid it if possible. RowIDs are used instead.
    - ROWIDs are used instead
    - https://sqlite.org/autoinc.html

- Maximum Number Of Rows In A Table
    - The theoretical maximum number of rows in a table is 264 (18446744073709551616 or about 1.8e+19). This limit is
      unreachable since the maximum database size of 281 terabytes will be reached first. A 281 terabytes database can
      hold no more than approximately 2e+13 rows, and then only if there are no indices and if each row contains very
      little data.
    - https://sqlite.org/limits.html

- WITHOUT ROWID is found only in SQLite and is not compatible with any other SQL database engine, as far as we know.
  - https://www.sqlite.org/withoutrowid.html

### SQL:
- Differencies:
  - https://sqlite.org/omitted.html
- SELECT statement syntax:
  - https://sqlite.org/lang_select.html

- Interesting stuff:
  - https://www.sqlite.org/quirks.html

- UUID as a standalone script:
  - Is it really necessary?
  - https://sqlite.org/src/file/ext/misc/uuid.c

### Testing

- Query Caching: https://sqlite-users.sqlite.narkive.com/7WO7PjK3/sqlite-caching
  - doesn't exist in SQLite
  - only page cache for the whole DB
    - https://stackoverflow.com/questions/5256906/how-do-i-get-sqlite-to-cache-results-of-a-select-command
    - https://www.sqlite.org/pragma.html#pragma_cache_size
- Read query timeout
  - https://stackoverflow.com/questions/8388155/specify-select-timeout-for-sqlite
  - not supported
- Docker Container changes RW permissions for each file inside copied volume
  - need to change permissions on host machine for entire folder - `chmod -R 777 /sqlite`

### Technical Specs

#### Consistency: ACID

- https://stackoverflow.com/questions/27075994/sqlite-vs-sql-server
  - SQLite locks the entire database when it needs a lock (either read or write) and only one writer can hold a write lock at a time. Due to its speed this actually isn't a problem for low to moderate size applications, but if you have a higher volume of writes (hundreds per second) then it could become a bottleneck.

- https://www.sqlite.org/atomiccommit.html
  - let's note all Disk Accesses - slow

- All changes within a single transaction in SQLite either occur completely or not at all, even if the act of writing the change out to the disk is interrupted by a program crash, an operating system crash, or a power failure.

- Notice that the shared lock is on the operating system disk cache, not on the disk itself. File locks really are just flags within the operating system kernel, usually.
  - OS has to acquire a lock on `File` itsel - hence the slowdown of each TX Read
  - Shared Lock on the level of OS Cache - hence no disk access (only at the start)
  
- 3.7. Flushing The Rollback Journal File To Mass Storage, 
  - 3.10. 0 Flushing Changes To Mass Storage
    - because of the inherent slowness of writing to disk or flash memory, this step together with the rollback journal file flush in section 3.7 above takes up `most of the time required to complete a transaction commit in SQLite`.

- 7. Optimizations
  - It follows then that anything we can do to reduce the amount of disk I/O will likely have a large positive impact on the performance of SQLite.

#### Scalability: Not designed for it.

- Only horizontal - multiple DB instances/files
  - "replicated SQLite"
    - https://github.com/rqlite/rqlite
    - https://litereplica.io/

- sharding - MongoDB
- vertical - more powerful hardware

- "Shardin" may not be ideal - https://stackoverflow.com/questions/128919/extreme-sharding-one-sqlite-database-per-user
  - shard walking problem and DB management/maintenance - what if schema changes per user DB?

- https://www.sqlite.org/draft/whentouse.html
  - When Read-Only queries are used the disk-access is fast - no Read Locks (concurrent DB connections)
- https://stackoverflow.com/questions/54998/how-scalable-is-sqlite - 2008
  - `This is because the entire database was locked every time someone viewed the page because it contained updates/inserts. I soon switched to MySQL...`
  - 