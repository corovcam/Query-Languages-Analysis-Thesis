.timer on

-- 7. Intersection

-- Find common tags between posts and persons

-- Tags associated with posts
SELECT Tag.tagId AS tagId, Tag.value AS commonTag
FROM Post_Tags
         JOIN Tag ON Post_Tags.tagId = Tag.tagId
INTERSECT
-- Tags associated with persons
SELECT Tag.tagId AS tagId, Tag.value AS commonTag
FROM Person_Tags
         JOIN Tag ON Person_Tags.tagId = Tag.tagId
ORDER BY tagId;