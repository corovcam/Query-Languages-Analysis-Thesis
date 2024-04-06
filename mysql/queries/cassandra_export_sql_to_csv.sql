SELECT postId,
    personId,
    imageFile,
    creationDate,
    locationIP,
    browserUsed,
    language,
    REPLACE(content, '\n', '\\n'),
    length INTO OUTFILE '/mysql/posts.tsv' FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\"' LINES TERMINATED BY '\n'
FROM Post;
SELECT * INTO OUTFILE '/mysql/posts_tags.tsv' FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\"' LINES TERMINATED BY '\n'
FROM Post_Tags;

-- Query 3.3.: Complex query to return Order details
SELECT o.orderId,
    o.customerId,
    p.personId,
    p.firstName,
    p.lastName,
    p.gender,
    p.birthday,
    p.street,
    p.city,
    p.postalCode,
    p.country,
    pr.productId,
    asin,
    title,
    price,
    brand,
    imageUrl,
    quantity,
    v.vendorId,
    v.name,
    v.country INTO OUTFILE '/mysql/exports/orders.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY "'" ESCAPED BY "'" LINES TERMINATED BY '\n'
FROM `Order` o
    JOIN Customer c ON o.customerId = c.customerId
    JOIN Person p ON c.personId = p.personId
    JOIN Order_Products op ON o.orderId = op.orderId
    JOIN Product pr ON op.productId = pr.productId
    JOIN Vendor_Products vp ON pr.productId = vp.productId
    JOIN Vendor v ON vp.vendorId = v.vendorId;

-- Query 1.2: Select people born between 1980-01-01 and 1990-12-31 (without index)
-- Query 3.4: Find all people having more than 1 friend
-- Query 5.1: Get a list of all people and their friend count (0 if they have no friends)
SELECT P1.*,
    COUNT(P2.personId) AS friendCount
INTO OUTFILE '/mysql/exports/person.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY "'" ESCAPED BY "'" LINES TERMINATED BY '\n'
FROM Person P1
    LEFT OUTER JOIN Person_Person PP on P1.personId = PP.personId1
    LEFT OUTER JOIN Person P2 on PP.personId2 = P2.personId
GROUP BY P1.personId;

-- Query 1.4 : Select people born between 1980-01-01 and 1990-12-31 (with index)
