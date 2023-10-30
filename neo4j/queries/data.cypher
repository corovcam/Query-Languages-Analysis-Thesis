:begin
MATCH (n) DETACH DELETE n;
:commit
:begin
CREATE CONSTRAINT UNIQUE_IMPORT_NAME FOR (node:`UNIQUE IMPORT LABEL`) REQUIRE (node.`UNIQUE IMPORT ID`) IS UNIQUE;
:commit
CALL db.awaitIndexes(300);
:begin
UNWIND [{_id:33, properties:{typeId:1, value:"Email"}}, {_id:34, properties:{typeId:2, value:"Phone"}}, {_id:35, properties:{typeId:3, value:"Address"}}, {_id:36, properties:{typeId:4, value:"Automotive"}}, {_id:37, properties:{typeId:5, value:"Electronics"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Type;
UNWIND [{_id:27, properties:{orderId:1}}, {_id:28, properties:{orderId:2}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Order;
UNWIND [{_id:42, properties:{imageFile:"post1.jpg", browserUsed:"Chrome", length:100, locationIp:"192.168.1.1", language:"English", postId:1, creationDate:localdatetime('2023-10-30T13:00:00'), content:"This is a sample post."}}, {_id:43, properties:{imageFile:"post2.jpg", browserUsed:"Firefox", length:120, locationIp:"192.168.1.2", language:"English", postId:2, creationDate:localdatetime('2023-10-30T14:00:00'), content:"Another sample post."}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Post;
UNWIND [{_id:38, properties:{customerId:1}}, {_id:39, properties:{customerId:2}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Customer;
UNWIND [{_id:29, properties:{country:"USA", name:"Vendor A", vendorId:1}}, {_id:30, properties:{country:"Canada", name:"Vendor B", vendorId:2}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Vendor;
UNWIND [{_id:40, properties:{tagId:1, value:"Technology"}}, {_id:41, properties:{tagId:2, value:"Travel"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Tag;
UNWIND [{_id:25, properties:{productId:1, price:19.99, imageUrl:"product1.jpg", asin:"ASIN123", title:"Product 1", brand:"Brand X"}}, {_id:26, properties:{productId:2, price:29.99, imageUrl:"product2.jpg", asin:"ASIN456", title:"Product 2", brand:"Brand Y"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Product;
UNWIND [{_id:31, properties:{birthday:localdatetime('1980-05-15T02:00:00'), country:"USA", firstName:"John", lastName:"Doe", gender:"Male", city:"New York", street:"123 Main St", postalCode:"10001", personId:1}}, {_id:32, properties:{birthday:localdatetime('1990-08-25T02:00:00'), country:"Canada", firstName:"Jane", lastName:"Smith", gender:"Female", city:"Toronto", street:"456 Elm St", postalCode:"M5V 1A1", personId:2}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Person;
:commit
:begin
UNWIND [{start: {_id:42}, end: {_id:40}, properties:{}}, {start: {_id:43}, end: {_id:41}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_TAG]->(end) SET r += row.properties;
UNWIND [{start: {_id:38}, end: {_id:31}, properties:{}}, {start: {_id:39}, end: {_id:32}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:IS_PERSON]->(end) SET r += row.properties;
UNWIND [{start: {_id:32}, end: {_id:40}, properties:{}}, {start: {_id:31}, end: {_id:41}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_INTEREST]->(end) SET r += row.properties;
UNWIND [{start: {_id:27}, end: {_id:33}, properties:{}}, {start: {_id:28}, end: {_id:33}, properties:{}}, {start: {_id:27}, end: {_id:34}, properties:{}}, {start: {_id:28}, end: {_id:34}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:ORDER_CONTACTS]->(end) SET r += row.properties;
UNWIND [{start: {_id:33}, end: {_id:29}, properties:{}}, {start: {_id:34}, end: {_id:29}, properties:{}}, {start: {_id:34}, end: {_id:30}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:VENDOR_CONTACTS]->(end) SET r += row.properties;
UNWIND [{start: {_id:27}, end: {_id:38}, properties:{}}, {start: {_id:28}, end: {_id:39}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:ORDERED_BY]->(end) SET r += row.properties;
UNWIND [{start: {_id:42}, end: {_id:31}, properties:{}}, {start: {_id:43}, end: {_id:32}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:CREATED_BY]->(end) SET r += row.properties;
UNWIND [{start: {_id:31}, end: {_id:32}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:KNOWS]->(end) SET r += row.properties;
UNWIND [{start: {_id:25}, end: {_id:29}, properties:{}}, {start: {_id:26}, end: {_id:29}, properties:{}}, {start: {_id:26}, end: {_id:30}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:MANUFACTURED_BY]->(end) SET r += row.properties;
UNWIND [{start: {_id:27}, end: {_id:25}, properties:{quantity:2}}, {start: {_id:28}, end: {_id:26}, properties:{quantity:3}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:ORDER_PRODUCTS]->(end) SET r += row.properties;
UNWIND [{start: {_id:36}, end: {_id:29}, properties:{}}, {start: {_id:37}, end: {_id:29}, properties:{}}, {start: {_id:37}, end: {_id:30}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:INDUSTRY]->(end) SET r += row.properties;
:commit
:begin
MATCH (n:`UNIQUE IMPORT LABEL`)  WITH n LIMIT 20000 REMOVE n:`UNIQUE IMPORT LABEL` REMOVE n.`UNIQUE IMPORT ID`;
:commit
:begin
DROP CONSTRAINT UNIQUE_IMPORT_NAME;
:commit
