const { db, aql } = require("@arangodb");
const fs = require("fs");

const iterations = 20;
const recordVolume = 256000;
const outFilePath = `logs/queries/results_${new Date().toISOString().replace(/:/g, '-')}.csv`;
let time;

fs.append(outFilePath, 'db,record_volume,query,iteration,time_in_seconds\n');

// Helper functions
function recordStats(row) {
  const [db, recordVolume, queryName, iteration, time] = row;
  fs.append(outFilePath, `${db},${recordVolume},${queryName},${iteration},${time}\n`);
}

function log(message) {
  const timestamp = `[${new Date().toISOString()}]`;
  console.log(`${timestamp}\t${message}`);
}

// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Selection

log('Started testing query 1.1');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR v IN vendors
    FILTER v.name == 'Bauch - Denesik'
    RETURN { vendorId: v.vendorId, name: v.name }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '1.1', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '1.1', -1, -1]);
}
log('Finished testing query 1.1');

// 1.2 Non-Indexed Selection - Range Query

try {
  db.persons.dropIndex('idx_person_birthday');
} catch (e) {
  // index does not exist
  log(e);
}

log('Started testing query 1.2');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR p IN persons
      FILTER DATE_TIMESTAMP(p.birthday) >= DATE_TIMESTAMP('1980-01-01') && DATE_TIMESTAMP(p.birthday) <= DATE_TIMESTAMP('1990-12-31')
      RETURN { personId: p.personId, firstName: p.firstName, lastName: p.lastName, birthday: p.birthday }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '1.2', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '1.2', -1, -1]);
}
log('Finished testing query 1.2');

// 1.3 Indexed Columns

db.vendors.ensureIndex(
  { type: "persistent", name: "idx_vendors_vendorID", unique: true, fields: ["vendorId"] }
);

log('Started testing query 1.3');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR n IN vendors
      FILTER n.vendorId == 24
      RETURN { vendorId: n.vendorId, name: n.name }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '1.3', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '1.3', -1, -1]);
}
log('Finished testing query 1.3');

// 1.4 Indexed Columns - Range Query

db.persons.ensureIndex(
  { type: "persistent", name: "idx_person_birthday", unique: false, fields: ["birthday"] }
);

log('Started testing query 1.4');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR p IN persons
      FILTER DATE_TIMESTAMP(p.birthday) >= DATE_TIMESTAMP('1980-01-01') && DATE_TIMESTAMP(p.birthday) <= DATE_TIMESTAMP('1990-12-31')
      RETURN { personId: p.personId, firstName: p.firstName, lastName: p.lastName, birthday: p.birthday }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '1.4', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '1.4', -1, -1]);
}
log('Finished testing query 1.4');

// 2. Aggregation

// 2.1 COUNT

log('Started testing query 2.1');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR pr IN products
      COLLECT brand = pr.brand WITH COUNT INTO productCount
      RETURN { brand: brand, productCount: productCount }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '2.1', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '2.1', -1, -1]);
}
log('Finished testing query 2.1');

// 2.2 MAX

log('Started testing query 2.2');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR pr IN products
      COLLECT brand = pr.brand
      AGGREGATE maxPrice = MAX(pr.price)
      RETURN { brand: brand, maxPrice: maxPrice }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '2.2', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '2.2', -1, -1]);
}
log('Finished testing query 2.2');

// 3. Join

// 3.1 Non-Indexed Node/Relationship keys

// TODO: Drop indexes for this query
// Primary Indexes cannot be dropped: https://docs.arangodb.com/3.11/index-and-search/indexing/basics/#primary-index
// Need to change the query? 

// Match all Orders and Vendors sharing the same Contact Type
// TODO: Rewrite to start iteration with i=1
log('Started testing query 3.1');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
      FOR o IN orders
        FOR t, oc IN OUTBOUND o contactType
          FOR v, vc IN OUTBOUND t contactType
            RETURN DISTINCT { typeId: t, order: o, orderContact: oc, vendor: v, vendorContact: vc }
    `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '3.1', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '3.1', -1, -1]);
}
log('Finished testing query 3.1');

// 3.2 Indexed Node/Relationship keys

// Match all Products contained in Orders

log('Started testing query 3.2');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR o IN orders
      FOR pr, cp IN OUTBOUND o containsProducts
        RETURN { product: pr, orderId: o.orderId, quantity: cp.rel.quantity }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '3.2', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '3.2', -1, -1]);
}
log('Finished testing query 3.2');

// 3.3 Complex Join 1

// Match all important information about Orders, Customers, People, Products and Vendors

log('Started testing query 3.3');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR o IN orders
      FOR c IN OUTBOUND o orderedBy
        FOR p IN OUTBOUND c isPerson
      FOR pr IN OUTBOUND o containsProducts
        FOR v IN OUTBOUND pr manufacturedBy
          RETURN { order: o, customer: c, person: p, product: pr, vendor: v }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '3.3', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '3.3', -1, -1]);
}
log('Finished testing query 3.3');

// 3.4 Complex Join 2 (having more than 1 friend)

log('Started testing query 3.4');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR p1 IN persons
      FOR p2 IN OUTBOUND p1 knows
        COLLECT originalPerson = p1 WITH COUNT INTO friendCount
        FILTER friendCount > 1
        RETURN { person: originalPerson, friendCount: friendCount }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '3.4', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '3.4', -1, -1]);
}
log('Finished testing query 3.4');

// 4. Unlimited Traversal

// 4.1 Find all direct and indirect relationships between people limited to 3 hops

log('Started testing query 4.1');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR p1 IN persons
      FOR p2 IN 0..3 ANY p1 knows
        RETURN DISTINCT { person1: p1, person2: p2 }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '4.1', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '4.1', -1, -1]);
}
log('Finished testing query 4.1');

// 4.2 Find the shortest path between two persons

log('Started testing query 4.2');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR p1 IN persons
      FILTER p1.personId == 774
      FOR p2 IN persons
        FILTER p2.personId == 12
        FOR v, e IN OUTBOUND SHORTEST_PATH p1 TO p2 knows
          RETURN v
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '4.2', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '4.2', -1, -1]);
}
log('Finished testing query 4.2');

// 5. Optional Traversal

// Get a list of all people and their friend count (0 if they have no friends)

log('Started testing query 5');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR p1 IN persons
      LET friends = (
        FOR p2 IN OUTBOUND p1 knows
        RETURN 1
      )
      RETURN { person: p1, friendCount: LENGTH(friends) }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '5', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '5', -1, -1]);
}
log('Finished testing query 5');

// 6. Union

// Get a list of contacts (email and phone) for both vendors and customers

log('Started testing query 6');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    LET vendorContacts = (
      FOR v IN vendors
        FOR t IN INBOUND v contactType
        RETURN { entityType: 'Vendor', entityId: v.vendorId, entityName: v.name, contactType: t.value }
    )

    LET orderContacts = (
      FOR p IN persons
        FOR c IN INBOUND p isPerson
        FOR o IN INBOUND c orderedBy
        FOR t IN OUTBOUND o contactType
        RETURN { entityType: 'Order', entityId: o.orderId, entityName: CONCAT(p.firstName, ' ', p.lastName), contactType: t.value }
    )

    RETURN UNION(vendorContacts, orderContacts)
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '6', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '6', -1, -1]);
}
log('Finished testing query 6');

// 7. Intersection

// Find common tags between posts AND persons

log('Started testing query 7');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    LET postTags = (
      FOR p IN posts
        FOR t IN OUTBOUND p hasTag
        RETURN { tagId: t.tagId, value: t.value }
    )

    LET personTags = (
      FOR p IN persons
        FOR t IN OUTBOUND p hasInterest
        RETURN { tagId: t.tagId, value: t.value }
    )

    RETURN INTERSECTION(postTags, personTags)
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '7', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '7', -1, -1]);
}
log('Finished testing query 7');

// 8. Difference

// Find people who have not made any orders

log('Started testing query 8');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR p IN persons
      FILTER LENGTH(
        FOR c IN INBOUND p isPerson
          FOR o IN INBOUND c orderedBy
            RETURN 1
      ) == 0
      RETURN p
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '8', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '8', -1, -1]);
}
log('Finished testing query 8');

// 9. Sorting

// 9.1 Non-Indexed property

log('Started testing query 9.1');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR pr IN products
      SORT pr.brand
      RETURN pr.brand
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '9.1', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '9.1', -1, -1]);
}
log('Finished testing query 9.1');

// 9.2 Indexed property

// _key is the default primary index for all collections

log('Started testing query 9.2');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR pr IN products
      SORT pr._key
      RETURN pr._key
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '9.2', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '9.2', -1, -1]);
}
log('Finished testing query 9.2');

// 10. Distinct

// Find unique combinations of product brands and the countries of the vendors selling those products

log('Started testing query 10');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR pr IN products
      FOR v IN OUTBOUND pr manufacturedBy
        //COLLECT brand = pr.brand, country = v.country
        SORT pr.brand, v.country
        RETURN DISTINCT { brand: pr.brand, country: v.country }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '10', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '10', -1, -1]);
}
log('Finished testing query 10');

// 11. MapReduce (not supported in ArangoDB, simple aggregation instead)

// Find the number of orders per customer

log('Started testing query 11');
try {
  for (let i = 0; i < iterations; i++) {
    time = db._query(aql`
    FOR c IN customers
      FOR o IN INBOUND c orderedBy
        COLLECT customerId = c.customerId WITH COUNT INTO orderCount
        RETURN { customerId: customerId, orderCount: orderCount }
  `).getExtra().stats.executionTime;

    recordStats(['arangodb', recordVolume, '11', i, time]);
  }
} catch (e) {
  log(e);
  recordStats(['arangodb', recordVolume, '11', -1, -1]);
}
log('Finished testing query 11');
