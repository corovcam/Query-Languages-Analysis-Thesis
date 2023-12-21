tracing on;
capture '/dev/null';

-- 11. MapReduce

-- Find the number of orders per customer (only those who have made at least 1 order)

SELECT customerId, COUNT(*) AS orderCount
FROM Orders_By_Customer
GROUP BY customerId;