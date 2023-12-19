.timer on

-- 8. Difference

-- Find people who have not made any orders

-- All people
SELECT personId, firstName, lastName
FROM Person
EXCEPT
-- People who have made orders
SELECT Person.personId, firstName, lastName
FROM Person
         JOIN Customer ON Person.personId = Customer.personId
         JOIN `Order` ON Customer.customerId = `Order`.customerId;