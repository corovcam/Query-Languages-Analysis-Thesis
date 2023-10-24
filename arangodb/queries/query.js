const { db, aql } = require("@arangodb");

db._query(aql`
  FOR v IN vendor
  RETURN v
`);

db._query(aql`
  FOR v IN vendor
  FILTER v.vendorId == 1
  RETURN v
`);

db._query(aql`
  FOR v IN vendor
  FILTER v.vendorId == 1 || v.vendorId == 2
  RETURN v
`);