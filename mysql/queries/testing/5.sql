-- 5.1 LEFT OUTER JOIN

-- Get a list of all people and their friend count (0 if they have no friends)
SELECT P1.personId,
       P1.firstName,
       P1.lastName,
       COUNT(P2.personId) AS friendCount
FROM Person P1
         LEFT OUTER JOIN Person_Person PP on P1.personId = PP.personId1
         LEFT OUTER JOIN Person P2 on PP.personId2 = P2.personId
GROUP BY P1.personId;