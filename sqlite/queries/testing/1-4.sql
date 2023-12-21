.timer on

-- 1.4 Indexed Columns - Range Query

CREATE INDEX IF NOT EXISTS idx_person_birthday ON Person (birthday);

SELECT personId, firstName, lastName, birthday
FROM Person
WHERE birthday BETWEEN '1980-01-01' AND '1990-12-31';