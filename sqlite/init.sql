.open ./ecommerce.db
CREATE TABLE ecommerce(timestamp TEXT, description TEXT);
INSERT INTO table_sample VALUES(datetime("now"),"First sample data. Foo");
INSERT INTO table_sample VALUES(datetime("now"),"Second sample data. Bar");
.quit