:begin
CREATE RANGE INDEX FOR (n:Vendor) ON (n.vendorId);
CREATE CONSTRAINT UNIQUE_IMPORT_NAME FOR (node:`UNIQUE IMPORT LABEL`) REQUIRE (node.`UNIQUE IMPORT ID`) IS UNIQUE;
:commit
CALL db.awaitIndexes(300);
:begin
UNWIND [{_id:94, properties:{typeId:1, value:"Email"}}, {_id:95, properties:{typeId:2, value:"Phone"}}, {_id:96, properties:{typeId:3, value:"Address"}}, {_id:97, properties:{typeId:4, value:"Automotive"}}, {_id:98, properties:{typeId:5, value:"Electronics"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Type;
UNWIND [{_id:80, properties:{orderId:1}}, {_id:81, properties:{orderId:2}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Order;
UNWIND [{_id:115, properties:{imageFile:"post1.jpg", browserUsed:"Chrome", length:100, locationIp:"192.168.1.1", language:"English", postId:1, creationDate:localdatetime('2023-10-30T13:00:00'), content:"This is a sample post."}}, {_id:116, properties:{imageFile:"post2.jpg", browserUsed:"Firefox", length:120, locationIp:"192.168.1.2", language:"English", postId:2, creationDate:localdatetime('2023-10-30T14:00:00'), content:"Another sample post."}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Post;
UNWIND [{_id:99, properties:{customerId:1}}, {_id:100, properties:{customerId:2}}, {_id:101, properties:{customerId:3}}, {_id:102, properties:{customerId:4}}, {_id:103, properties:{customerId:5}}, {_id:104, properties:{customerId:6}}, {_id:105, properties:{customerId:7}}, {_id:106, properties:{customerId:8}}, {_id:107, properties:{customerId:9}}, {_id:108, properties:{customerId:10}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Customer;
UNWIND [{_id:82, properties:{country:"USA", name:"Vendor A", vendorId:1}}, {_id:83, properties:{country:"Canada", name:"Vendor B", vendorId:2}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Vendor;
UNWIND [{_id:109, properties:{tagId:1, value:"Technology"}}, {_id:110, properties:{tagId:2, value:"Travel"}}, {_id:111, properties:{tagId:3, value:"Fashion"}}, {_id:112, properties:{tagId:4, value:"Food"}}, {_id:113, properties:{tagId:5, value:"Health"}}, {_id:114, properties:{tagId:6, value:"Sports"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Tag;
UNWIND [{_id:78, properties:{productId:1, price:19.99, imageUrl:"product1.jpg", asin:"ASIN123", title:"Product 1", brand:"Brand X"}}, {_id:79, properties:{productId:2, price:29.99, imageUrl:"product2.jpg", asin:"ASIN456", title:"Product 2", brand:"Brand Y"}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Product;
UNWIND [{_id:84, properties:{birthday:date('1980-05-15'), country:"USA", firstName:"John", lastName:"Doe", gender:"Male", city:"New York", street:"123 Main St", postalCode:"10001", personId:1}}, {_id:85, properties:{birthday:date('1990-08-25'), country:"Canada", firstName:"Jane", lastName:"Smith", gender:"Female", city:"Toronto", street:"456 Elm St", postalCode:"M5V 1A1", personId:2}}, {_id:86, properties:{birthday:date('1983-03-10'), country:"UK", firstName:"Michael", lastName:"Johnson", gender:"Male", city:"London", street:"789 Oak St", postalCode:"EC1A 1BB", personId:3}}, {_id:87, properties:{birthday:date('1986-06-20'), country:"Germany", firstName:"Sophia", lastName:"Müller", gender:"Female", city:"Berlin", street:"101 Birch St", postalCode:"10115", personId:4}}, {_id:88, properties:{birthday:date('1995-01-05'), country:"France", firstName:"Alex", lastName:"Dupont", gender:"Male", city:"Paris", street:"456 Maple St", postalCode:"75001", personId:5}}, {_id:89, properties:{birthday:date('1990-12-15'), country:"Italy", firstName:"Giulia", lastName:"Rossi", gender:"Female", city:"Rome", street:"789 Vine St", postalCode:"00100", personId:6}}, {_id:90, properties:{birthday:date('1980-08-01'), country:"Japan", firstName:"Takashi", lastName:"Yamamoto", gender:"Male", city:"Tokyo", street:"123 Sakura St", postalCode:"100-0001", personId:7}}, {_id:91, properties:{birthday:date('1992-05-30'), country:"Australia", firstName:"Mia", lastName:"Johnson", gender:"Female", city:"Sydney", street:"456 Cherry St", postalCode:"2000", personId:8}}, {_id:92, properties:{birthday:date('1985-11-18'), country:"Australia", firstName:"Lucas", lastName:"Silva", gender:"Male", city:"Melbourne", street:"789 Kangaroo St", postalCode:"3000", personId:9}}, {_id:93, properties:{birthday:date('1991-04-25'), country:"Brazil", firstName:"Isabella", lastName:"Pereira", gender:"Female", city:"Rio de Janeiro", street:"101 Copacabana St", postalCode:"20000-000", personId:10}}] AS row
CREATE (n:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row._id}) SET n += row.properties SET n:Person;
:commit
:begin
UNWIND [{start: {_id:94}, end: {_id:82}, properties:{}}, {start: {_id:95}, end: {_id:82}, properties:{}}, {start: {_id:95}, end: {_id:83}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:CONTACT_TYPE]->(end) SET r += row.properties;
UNWIND [{start: {_id:115}, end: {_id:109}, properties:{}}, {start: {_id:116}, end: {_id:109}, properties:{}}, {start: {_id:116}, end: {_id:110}, properties:{}}, {start: {_id:115}, end: {_id:111}, properties:{}}, {start: {_id:116}, end: {_id:112}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_TAG]->(end) SET r += row.properties;
UNWIND [{start: {_id:99}, end: {_id:84}, properties:{}}, {start: {_id:100}, end: {_id:85}, properties:{}}, {start: {_id:101}, end: {_id:86}, properties:{}}, {start: {_id:102}, end: {_id:87}, properties:{}}, {start: {_id:103}, end: {_id:88}, properties:{}}, {start: {_id:104}, end: {_id:89}, properties:{}}, {start: {_id:105}, end: {_id:90}, properties:{}}, {start: {_id:106}, end: {_id:91}, properties:{}}, {start: {_id:107}, end: {_id:92}, properties:{}}, {start: {_id:108}, end: {_id:93}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:IS_PERSON]->(end) SET r += row.properties;
UNWIND [{start: {_id:97}, end: {_id:82}, properties:{}}, {start: {_id:98}, end: {_id:82}, properties:{}}, {start: {_id:98}, end: {_id:83}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:INDUSTRY_TYPE]->(end) SET r += row.properties;
UNWIND [{start: {_id:85}, end: {_id:109}, properties:{}}, {start: {_id:84}, end: {_id:110}, properties:{}}, {start: {_id:87}, end: {_id:111}, properties:{}}, {start: {_id:86}, end: {_id:112}, properties:{}}, {start: {_id:89}, end: {_id:113}, properties:{}}, {start: {_id:88}, end: {_id:114}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:HAS_INTEREST]->(end) SET r += row.properties;
UNWIND [{start: {_id:80}, end: {_id:99}, properties:{}}, {start: {_id:81}, end: {_id:100}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:ORDERED_BY]->(end) SET r += row.properties;
UNWIND [{start: {_id:115}, end: {_id:84}, properties:{}}, {start: {_id:116}, end: {_id:85}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:CREATED_BY]->(end) SET r += row.properties;
UNWIND [{start: {_id:93}, end: {_id:84}, properties:{}}, {start: {_id:84}, end: {_id:85}, properties:{}}, {start: {_id:84}, end: {_id:86}, properties:{}}, {start: {_id:84}, end: {_id:87}, properties:{}}, {start: {_id:86}, end: {_id:87}, properties:{}}, {start: {_id:84}, end: {_id:88}, properties:{}}, {start: {_id:87}, end: {_id:88}, properties:{}}, {start: {_id:89}, end: {_id:90}, properties:{}}, {start: {_id:89}, end: {_id:91}, properties:{}}, {start: {_id:90}, end: {_id:91}, properties:{}}, {start: {_id:89}, end: {_id:92}, properties:{}}, {start: {_id:87}, end: {_id:93}, properties:{}}, {start: {_id:89}, end: {_id:93}, properties:{}}, {start: {_id:92}, end: {_id:93}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:KNOWS]->(end) SET r += row.properties;
UNWIND [{start: {_id:80}, end: {_id:78}, properties:{quantity:2}}, {start: {_id:81}, end: {_id:79}, properties:{quantity:3}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:CONTAINS_PRODUCTS]->(end) SET r += row.properties;
UNWIND [{start: {_id:78}, end: {_id:82}, properties:{}}, {start: {_id:79}, end: {_id:82}, properties:{}}, {start: {_id:79}, end: {_id:83}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:MANUFACTURED_BY]->(end) SET r += row.properties;
UNWIND [{start: {_id:80}, end: {_id:94}, properties:{}}, {start: {_id:81}, end: {_id:94}, properties:{}}, {start: {_id:80}, end: {_id:95}, properties:{}}, {start: {_id:81}, end: {_id:95}, properties:{}}] AS row
MATCH (start:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.start._id})
MATCH (end:`UNIQUE IMPORT LABEL`{`UNIQUE IMPORT ID`: row.end._id})
CREATE (start)-[r:CONTACT_TYPE]->(end) SET r += row.properties;
:commit
:begin
MATCH (n:`UNIQUE IMPORT LABEL`)  WITH n LIMIT 20000 REMOVE n:`UNIQUE IMPORT LABEL` REMOVE n.`UNIQUE IMPORT ID`;
:commit
:begin
DROP CONSTRAINT UNIQUE_IMPORT_NAME;
:commit
