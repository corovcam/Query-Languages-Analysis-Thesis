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