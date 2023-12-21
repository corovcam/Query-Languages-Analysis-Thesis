-- 11. MapReduce

-- Find the number of orders per customer (only those who have made at least 1 order)

SELECT Customer.customerId, COUNT(*) AS orderCount
FROM Customer
         JOIN `Order` ON Customer.customerId = `Order`.customerId
GROUP BY Customer.customerId;