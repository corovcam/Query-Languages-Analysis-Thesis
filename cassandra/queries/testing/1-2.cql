tracing on;
capture '/dev/null';

-- 1.2 Non-Indexed Columns - Range Query

-- Select people born between 1980-01-01 and 1990-12-31
SELECT personId, firstName, lastName, birthday
FROM Person
WHERE birthday >= '1980-01-01'
  AND birthday <= '1990-12-31'
    ALLOW FILTERING;