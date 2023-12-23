-- 3.4 Complex Join 2 (having more than 1 friend)

SELECT P1.*, COUNT(*) AS friendCount
FROM Person P1
         INNER JOIN Person_Person PP on P1.personId = PP.personId1
GROUP BY P1.personId
HAVING COUNT(*) > 1;