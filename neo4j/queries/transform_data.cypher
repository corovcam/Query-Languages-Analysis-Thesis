// DROP automatic LOOKUP index for Node labels
DROP INDEX index_f7700477 IF EXISTS;
// DROP automatic LOOKUP index for Relationship labels
DROP INDEX index_343aff4e IF EXISTS;

// Re-create the LOOKUP indexes - this time as manual indexes to know the index name
CREATE LOOKUP INDEX node_label_lookup_index IF NOT EXISTS FOR (n) ON EACH labels(n);
CREATE LOOKUP INDEX rel_type_lookup_index IF NOT EXISTS FOR ()-[r]-() ON EACH type(r);

CREATE INDEX idx_vendor_vendorId IF NOT EXISTS FOR (v:Vendor) ON (v.vendorId);

MATCH (p:Person)
SET p.birthday = date(p.birthday);

// MATCH (p:Person)
// WITH split(p.birthday, ' ') AS datetime
// SET p.birthday = date(datetime[0]);
