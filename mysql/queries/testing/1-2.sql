-- 1.2 Non-Indexed Columns - Range Query

CALL drop_birthday_index_if_exists();

-- Select people born between 1980-01-01 and 1990-12-31
SELECT personId, firstName, lastName, birthday
FROM Person
WHERE birthday BETWEEN '1980-01-01' AND '1990-12-31';