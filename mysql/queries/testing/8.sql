-- 8. Difference

-- Find people who have not made any orders

-- All people
SELECT personId, firstName, lastName
FROM Person
WHERE personId NOT IN ( -- EXCEPT is not supported in MySQL, it is available in >8.0 though ????
-- People who have made orders
    SELECT Person.personId
    FROM Person
             JOIN Customer ON Person.personId = Customer.personId
             JOIN `Order` ON Customer.customerId = `Order`.customerId);