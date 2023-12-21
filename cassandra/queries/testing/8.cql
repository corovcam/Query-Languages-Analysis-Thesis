tracing on;
capture '/dev/null';

-- 8. Difference

-- Find people who have not made any orders

SELECT personId, firstName, lastName
FROM Orders_By_Person
WHERE ordersCreated CONTAINS -1
    ALLOW FILTERING;