-- 4.2. Shortest path

-- TODO: Guessing the max recursion depth to be 10 million ??
SET SESSION cte_max_recursion_depth = 10000000;

-- Find the shortest path between two persons using WITH RECURSIVE
WITH RECURSIVE PersonPath AS (SELECT personId1 AS sourcePersonId,
                                     personId2 AS targetPersonId,
                                     personId1 AS currentPersonId,
                                     1         AS depth
                              FROM Person_Person
                              WHERE personId1 = 774 -- Specify the source person ID
                              UNION
                              SELECT pp.sourcePersonId,
                                     pp.targetPersonId,
                                     pp.currentPersonId,
                                     pp.depth + 1 AS depth
                              FROM PersonPath pp
                                       JOIN Person_Person pp2 ON pp.currentPersonId = pp2.personId1
                              WHERE pp.currentPersonId <> 12) -- Specify the target person ID
SELECT *
FROM PersonPath
WHERE targetPersonId = 12
ORDER BY depth
LIMIT 1;


-- 4.2. Shortest path

-- TODO: Guessing the max recursion depth to be 10 million ??
SET SESSION cte_max_recursion_depth = 10000000;

WITH RECURSIVE PersonPath AS
                   (SELECT personId2                        AS friend,
                           JSON_ARRAY(personId1, personId2) AS path_ids,
                           1                                AS depth,
                           personId1 = personId2            AS is_visited
                    FROM Person_Person
                    WHERE personId1 = 774
                    UNION ALL
                    SELECT personId2,
                           JSON_ARRAY_APPEND(path_ids, '$', d.personId2),
                           f.depth + 1,
                           d.personId2 MEMBER OF(path_ids)
                    FROM PersonPath f
                             JOIN Person_Person d
                                  ON d.personId1 = friend
                    WHERE friend <> 12
                      AND f.is_visited <> 1)
SELECT *
FROM PersonPath
WHERE friend = 12
ORDER BY depth
LIMIT 1;