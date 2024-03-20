SELECT postId, personId, imageFile, creationDate, locationIP, browserUsed, language, REPLACE(content, '\n', '\\n'), length
INTO OUTFILE '/mysql/posts.tsv'
    FIELDS TERMINATED BY '\t'
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '\"'
    LINES TERMINATED BY '\n'
FROM Post;

SELECT *
INTO OUTFILE '/mysql/posts_tags.tsv'
    FIELDS TERMINATED BY '\t'
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '\"'
    LINES TERMINATED BY '\n'
FROM Post_Tags;