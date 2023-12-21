tracing on;
capture '/dev/null';

-- 9.2 Indexed Columns

-- In Cassandra, without specifying the clustering columns, the results are returned in the order of the partition key
SELECT *
FROM Product;