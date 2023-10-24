:begin
MATCH (n) DETACH DELETE n;
:commit
:begin
CREATE CONSTRAINT UNIQUE_IMPORT_NAME FOR (node:`UNIQUE IMPORT LABEL`) REQUIRE (node.`UNIQUE IMPORT ID`) IS UNIQUE;
:commit
CALL db.awaitIndexes(300);
:begin
UNWIND [{_id:0, properties:{country:"USA", name:"Amazon", vendorId:1}}, {_id:1, properties:{country:"USA", name:"Walmart", vendorId:2}}, {_id:2, properties:{country:"USA", name:"Target", vendorId:3}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Vendor;
UNWIND [{_id:3, properties:{productId:1, price:699.99, imageUrl:"https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg", asin:"B07H65KP63", title:"Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)", brand:"Apple"}}, {_id:4, properties:{productId:2, price:699.99, imageUrl:"https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg", asin:"B07H65KP63", title:"Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)", brand:"Apple"}}, {_id:5, properties:{productId:3, price:699.99, imageUrl:"https://m.media-amazon.com/images/I/41MfUOQ+MvL._AC_UY218_.jpg", asin:"B07H65KP63", title:"Apple iPhone XS Max, 256GB, Gold - Fully Unlocked (Renewed)", brand:"Apple"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Product;
:commit
:begin
UNWIND [{start: {_id:3}, end: {_id:0}, properties:{}}, {start: {_id:4}, end: {_id:1}, properties:{}}, {start: {_id:5}, end: {_id:2}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:VENDOR_PRODUCTS]->(end) SET r += row.properties;
:commit
:begin
MATCH (n:`UNIQUE IMPORT LABEL`)  WITH n LIMIT 20000 REMOVE n:`UNIQUE IMPORT LABEL` REMOVE n.`UNIQUE IMPORT ID`;
:commit
:begin
DROP CONSTRAINT UNIQUE_IMPORT_NAME;
:commit
