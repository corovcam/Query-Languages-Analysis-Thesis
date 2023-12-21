-- 1.4 Indexed Columns - Range Query
CALL create_birthday_index_if_not_exists();

-- Select people born between 1980-01-01 and 1990-12-31 (using index)
SELECT personId, firstName, lastName, birthday
FROM Person
WHERE birthday BETWEEN '1980-01-01' AND '1990-12-31';