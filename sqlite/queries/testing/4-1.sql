.timer on

-- 4.1 Find all direct and indirect relationships between people

WITH RECURSIVE PersonRelationships AS (SELECT personId1 AS sourcePersonId,
                                              personId2 AS relatedPersonId,
                                              1         AS depth
                                       FROM Person_Person
                                       UNION
                                       SELECT pr.sourcePersonId,
                                              pp.personId2 AS relatedPersonId,
                                              pr.depth + 1 AS depth
                                       FROM PersonRelationships pr
                                                JOIN Person_Person pp ON pr.relatedPersonId = pp.personId1
                                       WHERE pr.depth < 3 -- Limiting recursion depth to 3 for illustration
)
SELECT *
FROM PersonRelationships
ORDER BY sourcePersonId, depth, relatedPersonId;