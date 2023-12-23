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
                                AND personId2 = 12  -- Specify the target person ID
                              UNION
                              SELECT pp.sourcePersonId,
                                     pp.targetPersonId,
                                     pp.currentPersonId,
                                     pp.depth + 1 AS depth
                              FROM PersonPath pp
                                       JOIN Person_Person pp2 ON pp.currentPersonId = pp2.personId1
                              WHERE pp.currentPersonId <> pp.targetPersonId)
SELECT *
FROM PersonPath
ORDER BY sourcePersonId, depth, targetPersonId;