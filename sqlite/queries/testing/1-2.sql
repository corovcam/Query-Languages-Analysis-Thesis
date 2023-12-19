.timer on

-- 1.2 Non-Indexed Columns - Range Query
DROP INDEX IF EXISTS idx_person_birthday;

SELECT personId, firstName, lastName, birthday
FROM Person
WHERE birthday BETWEEN '1980-01-01' AND '1990-12-31';