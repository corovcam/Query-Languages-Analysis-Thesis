tracing on;
capture '/dev/null';

-- 1.4 Indexed Columns - Range Query

-- Select people born between 1980-01-01 and 1990-12-31 (using index)
SELECT personId, firstName, lastName, birthday
FROM Person_By_Birthday_Indexed
WHERE birthday >= '1980-01-01'
  AND birthday <= '1990-12-31'
    ALLOW FILTERING;