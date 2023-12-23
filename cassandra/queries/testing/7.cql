tracing on;
capture '/dev/null';

-- 7. Intersection

SELECT tagId, value
FROM Tag
WHERE interestedPeople CONTAINS -1 AND postsTagged CONTAINS -1
    ALLOW FILTERING;