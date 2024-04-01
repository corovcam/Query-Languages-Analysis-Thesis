## Testing

- Turn off query cache
  - https://dev.mysql.com/doc/refman/5.7/en/query-cache-configuration.html
  - turned off by default in 8.0
- Query Performance Schema - measuring execution time
  - https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-query-profiling.html
    ```SQL
    UPDATE performance_schema.setup_instruments
    SET ENABLED = 'YES', TIMED = 'YES'
    WHERE NAME LIKE '%statement/%';
    UPDATE performance_schema.setup_instruments
    SET ENABLED = 'YES', TIMED = 'YES'
    WHERE NAME LIKE '%stage/%';
    ```
    ```SQL
    UPDATE performance_schema.setup_consumers
    SET ENABLED = 'YES'
    WHERE NAME LIKE '%events_statements_%';
    UPDATE performance_schema.setup_consumers
    SET ENABLED = 'YES'
    WHERE NAME LIKE '%events_stages_%';
    ```

- jdbc conn string: jdbc:mysql://127.0.0.1/ecommerce?sslMode=preferred&autoReconnect=true&autoReconnectForPools=true

## Stats

- Volumes:
  - 256k
    ```
    Table,Size (kB)
    Post,187600
    Order_Contacts,128544
    Person_Person,82048
    Person_Tags,82048
    Post_Tags,82048
    Order_Products,63616
    Vendor_Contacts,62768
    Vendor_Products,45136
    Product,35392
    Person,30272
    Industry,19488
    Order,16416
    Vendor,14864
    Tag,12816
    Customer,8224
    Type,16
    ```
  - 512k:
    ```
    Table,Size (kB)
    Order_Contacts,275360
    Person_Person,162000
    Person_Tags,151744
    Post_Tags,146624
    Order_Products,137440
    Post,126096
    Vendor_Contacts,124416
    Product,71264
    Person,59984
    Industry,50256
    Order,32832
    Vendor,30272
    Tag,25136
    Vendor_Products,22560
    Customer,16416
    Type,16
    ```

- Row count
  - 256k
    ```
    table_name,exact_row_count
    Customer,170627
    Industry,383829
    Order,341365
    Order_Contacts,1024095
    Order_Products,1025494
    Person,256000
    Person_Person,1279600
    Person_Tags,1281585
    Post,256000
    Post_Tags,1279277
    Product,256000
    Tag,256000
    Type,13
    Vendor,256000
    Vendor_Contacts,511961
    Vendor_Products,702504
    ```
  - 512k
    ```
    table_name,exact_row_count
    Customer,371187
    Industry,1023699
    Order,742467
    Order_Contacts,2227401
    Order_Products,2225484
    Person,512000
    Person_Person,2561390
    Person_Tags,2557056
    Post,512000
    Post_Tags,2562686
    Product,512000
    Tag,512000
    Type,13
    Vendor,512000
    Vendor_Contacts,1023509
    Vendor_Products,512000
    ```