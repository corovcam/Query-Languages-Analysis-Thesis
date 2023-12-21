tracing on;
capture '/dev/null';

-- 3.4 Complex Join 2 (having more than 1 friend)

SELECT *
FROM Person
WHERE friendCount > 1
    ALLOW FILTERING;