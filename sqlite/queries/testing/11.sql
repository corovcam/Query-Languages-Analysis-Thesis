.timer on

-- 11. MapReduce

-- Find the number of orders per customer

SELECT Customer.customerId, COUNT(*) AS orderCount
FROM Customer
         JOIN `Order` ON Customer.customerId = `Order`.customerId
GROUP BY Customer.customerId;