const fs = require("fs");

if (!process.env.RECORD_VOLUME) {
  console.log("You have to specify record_volume variable.");
  process.exit(1);
}

const iterations = 20;
const recordVolume = process.env.RECORD_VOLUME;
const outFilePath = `logs/queries/results_${new Date().toISOString().replace(/:/g, '-')}.csv`;
const maxTimeMS = 300000;
let time, timeout;

fs.appendFileSync(outFilePath, 'db,record_volume,query,iteration,time_in_seconds\n');

// Helper functions
function recordStats(queryName, iteration, time) {
  fs.appendFileSync(outFilePath, `mongodb,${recordVolume},${queryName},${iteration},${time}\n`);
}

function log(message) {
  const timestamp = `[${new Date().toISOString()}]`;
  console.log(`${timestamp}\t${message}`);
}

function killLongRunningOps() {
  currOp = db.currentOp();
  for (oper in currOp.inprog) {
    op = currOp.inprog[oper - 0];
    if (op.op == "command" && op.ns.startsWith("ecommerce")) {
      log("Killing opId: " + op.opid + " running for over secs: " + op.secs_running);
      db.killOp(op.opid);
    }
  }
};

function startTimeout() {
  const timeout = setTimeout(() => {
    log('Timeout reached, killing long running operations...');
    killLongRunningOps();
    throw new Error('Timeout reached');
  }, maxTimeMS);
  return timeout;
}

// Set cursor (query) timeout to 5 minutes
db.adminCommand({ setParameter: 1, cursorTimeoutMillis: maxTimeMS });

// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Attributes

log('Started testing query 1.1');
try {
  for (let i = 0; i < iterations; i++) {
    db.vendors.getPlanCache().clear();
    time = db.vendors.find({ name: "Bauch - Denesik" }, { name: 1 }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('1.1', i, time);
  }
} catch (e) {
  recordStats('1.1', -1, -1);
  log(e);
}
log('Finished testing query 1.1');

// 1.2 Non-Indexed Attributes - Range Query

// Drop index on birthday attribute if exists
db.persons.dropIndex({ birthday: 1 });

log('Started testing query 1.2');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    time = db.persons.find({ birthday: { $gte: ISODate('1980-01-01'), $lte: ISODate('1990-12-31') } }, { firstName: 1, lastName: 1, birthday: 1 }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('1.2', i, time);
  }
} catch (e) {
  recordStats('1.2', -1, -1);
  log(e);
}
log('Finished testing query 1.2');

// 1.3 Indexed Attributes

log('Started testing query 1.3');
try {
  for (let i = 0; i < iterations; i++) {
    db.vendors.getPlanCache().clear();
    time = db.vendors.find({ _id: 24 }, { name: 1 }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('1.3', i, time);
  }
} catch (e) {
  recordStats('1.3', -1, -1);
  log(e);
}
log('Finished testing query 1.3');

// 1.4 Indexed Attributes - Range Query

// Create index on birthday attribute
db.persons.createIndex({ birthday: 1 });

log('Started testing query 1.4');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    time = db.persons.find({ birthday: { $gte: ISODate('1980-01-01'), $lte: ISODate('1990-12-31') } }, { firstName: 1, lastName: 1, birthday: 1 }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('1.4', i, time);
  }
} catch (e) {
  recordStats('1.4', -1, -1);
  log(e);
}
log('Finished testing query 1.4');

// 2. Aggregation

// 2.1 COUNT

log('Started testing query 2.1');
try {
  for (let i = 0; i < iterations; i++) {
    db.products.getPlanCache().clear();
    timeout = startTimeout();
    time = db.products.explain("executionStats").aggregate([{ $group: { _id: "$brand", productCount: { $sum: 1 } } }]).executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('2.1', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('2.1', -1, -1);
  log(e);
}
log('Finished testing query 2.1');

// 2.2 MAX

log('Started testing query 2.2');
try {
  for (let i = 0; i < iterations; i++) {
    db.products.getPlanCache().clear();
    time = db.products.explain("executionStats").aggregate([{ $group: { _id: "$brand", maxPrice: { $max: "$price" } } }]).executionStats.executionTimeMillis / 1000;
    recordStats('2.2', i, time);
  }
} catch (e) {
  recordStats('2.2', -1, -1);
  log(e);
}
log('Finished testing query 2.2');

// 3. Join

// 3.1 Non-Indexed Attributes

if (recordVolume >= 128000) {
  log('Started testing query 3.1');
  try {
    for (let i = 0; i < iterations; i++) {
      db.types.getPlanCache().clear();
      timeout = startTimeout();
      time = db.types.explain("executionStats").aggregate([
        {
          $lookup: {
            from: "orders",
            localField: "_id",
            foreignField: "contacts.typeId",
            as: "orderContacts"
          }
        },
        {
          $lookup: {
            from: "vendors",
            localField: "_id",
            foreignField: "contacts.typeId",
            as: "vendorContacts"
          }
        },
        {
          $unwind: "$orderContacts"
        },
        {
          $unwind: "$vendorContacts"
        },
        {
          $project: {
            orderContact: {
              orderId: "$orderContacts.orderId",
              value: "$orderContacts.value",
            },
            vendorContact: {
              vendorId: "$vendorContacts.vendorId",
              value: "$vendorContacts.value",
            },
          }
        }
      ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
      clearTimeout(timeout);
      recordStats('3.1', i, time);
    }
  } catch (e) {
    clearTimeout(timeout);
    recordStats('3.1', -1, -1);
    log(e);
  }
  log('Finished testing query 3.1');
} else {
  // Using this only for < 128k entity experiments
  log('Started testing query 3.1');
  try {
    for (let i = 0; i < iterations; i++) {
      db.types.getPlanCache().clear();
      timeout = startTimeout();
      time = db.types.explain("executionStats").aggregate([
        {
          $unwind: "$orderContacts"
        },
        {
          $unwind: "$vendorContacts"
        },
        {
          $project: {
            orderContact: {
              orderId: "$orderContacts.orderId",
              value: "$orderContacts.value",
            },
            vendorContact: {
              vendorId: "$vendorContacts.vendorId",
              value: "$vendorContacts.value",
            },
          }
        }
      ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
      clearTimeout(timeout);
      recordStats('3.1', i, time);
    }
  } catch (e) {
    clearTimeout(timeout);
    recordStats('3.1', -1, -1);
    log(e);
  }
  log('Finished testing query 3.1');
}

// 3.2 Indexed Attributes

log('Started testing query 3.2');
try {
  for (let i = 0; i < iterations; i++) {
    db.products.getPlanCache().clear();
    time = db.products.find().maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('3.2', i, time);
  }
} catch (e) {
  recordStats('3.2', -1, -1);
  log(e);
}
log('Finished testing query 3.2');

// 3.3 Complex Join 1

// Complex query with "lookup" to retrieve order details

if (recordVolume >= 128000) {
  // Need to join "vendors" and "orders" on "containsProducts.productId" and "manufacturesProducts.productId" respectively
  log('Started testing query 3.3');
  try {
    for (let i = 0; i < iterations; i++) {
      db.orders.getPlanCache().clear();
      db.vendors.getPlanCache().clear();
      timeout = startTimeout();
      time = db.orders.explain("executionStats").aggregate([
        {
          $lookup: {
            from: "products",
            localField: "_id",
            foreignField: "products.inOrders.orderId",
            as: "containsProducts"
          }
        },
        {
          $unwind: "$containsProducts"
        },
        {
          $lookup: {
            from: "vendors",
            localField: "containsProducts.productId",
            foreignField: "manufacturesProducts.productId",
            as: "containsProducts.vendors"
          }
        },
        {
          $unset: [
            "containsProducts.vendors.manufacturesProducts",
            "containsProducts.vendors.contacts"
          ],
        },
      ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
      clearTimeout(timeout);
      recordStats('3.3', i, time);
    }
  } catch (e) {
    clearTimeout(timeout);
    recordStats('3.3', -1, -1);
    log(e);
  }
  log('Finished testing query 3.3');
} else {
  // Using this only for < 256k entity experiments
  log('Started testing query 3.3');
  try {
    for (let i = 0; i < iterations; i++) {
      db.orders.getPlanCache().clear();
      db.vendors.getPlanCache().clear();
      timeout = startTimeout();
      time = db.orders.explain("executionStats").aggregate([
        {
          $unwind: "$containsProducts"
        },
        {
          $lookup: {
            from: "vendors",
            localField: "containsProducts.productId",
            foreignField: "manufacturesProducts.productId",
            as: "containsProducts.vendors"
          }
        },
        {
          $unset: [
            "containsProducts.vendors.manufacturesProducts",
            "containsProducts.vendors.contacts"
          ],
        },
      ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
      clearTimeout(timeout);
      recordStats('3.3', i, time);
    }
  } catch (e) {
    clearTimeout(timeout);
    recordStats('3.3', -1, -1);
    log(e);
  }
  log('Finished testing query 3.3');
}

// 3.4 Complex Join 2 (having more than 1 friend)

// Follower Count (not both way friendship)
log('Started testing query 3.4');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    timeout = startTimeout();
    time = db.persons.explain("executionStats").aggregate([
      {
        $unwind: "$knowsPeople"
      },
      {
        $group: {
          _id: "$knowsPeople",
          followerCount: { $sum: 1 }
        }
      },
      {
        $match: {
          followerCount: { $gt: 1 }
        }
      },
      {
        $lookup: {
          from: "persons",
          localField: "_id",
          foreignField: "_id",
          as: "person"
        }
      },
      {
        $replaceRoot: { newRoot: { $mergeObjects: [{ $arrayElemAt: ["$person", 0] }, "$$ROOT"] } }
      },
      { $project: { person: 0, knowsPeople: 0 } }
    ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('3.4', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('3.4', -1, -1);
  log(e);
}
log('Finished testing query 3.4');

// 4. Unlimited Traversal

// 4.1 Find all direct and indirect relationships between people up to 4 (0, 1, 2, 3) levels deep

log('Started testing query 4.1');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    timeout = startTimeout();
    time = db.persons.explain("executionStats").aggregate([
      {
        $graphLookup: {
          from: "persons",
          startWith: "$knowsPeople",
          connectFromField: "knowsPeople",
          connectToField: "_id",
          as: "relationships",
          maxDepth: 3,
          depthField: "depth"
        }
      },
      {
        $unwind: "$relationships"
      },
      {
        $project: {
          _id: 0,
          sourcePersonId: "$_id",
          relatedPersonId: "$relationships._id",
        }
      },
    ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('4.1', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('4.1', -1, -1);
  log(e);
}
log('Finished testing query 4.1');

// 4.2 Find the shortest path between two persons using $graphLookup

log('Started testing query 4.2');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    timeout = startTimeout();
    time = db.persons.explain("executionStats").aggregate([
      {
        $match: {
          _id: 774
        }
      },
      {
        $graphLookup: {
          from: "persons",
          startWith: "$_id",
          connectFromField: "knowsPeople",
          connectToField: "_id",
          as: "relationships",
          depthField: "depth",
          restrictSearchWithMatch: {
            _id: { $ne: 12 }
          }
        }
      },
      {
        $unwind: "$relationships"
      },
      {
        $project: {
          _id: 0,
          relationships: 1,
        }
      },
      {
        $replaceRoot: { newRoot: { $mergeObjects: ["$relationships", "$$ROOT"] } }
      },
      {
        $addFields: {
          knowsPeople: "$relationships.knowsPeople",
        }
      },
      {
        $unset: ["relationships"]
      },
      {
        $sort: {
          depth: 1,
        }
      }
    ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('4.2', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('4.2', -1, -1);
  log(e);
}
log('Finished testing query 4.2');

// 5. Optional Traversal

log('Started testing query 5');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    time = db.persons.find({}, {
      firstName: 1,
      lastName: 1,
      friendCount: {
        $cond: {
          if: { $isArray: "$knowsPeople" },
          then: { $size: "$knowsPeople" },
          else: 0
        }
      }
    }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('5', i, time);
  }
} catch (e) {
  recordStats('5', -1, -1);
  log(e);
}
log('Finished testing query 5');

// 6. UNION

log('Started testing query 6');
try {
  for (let i = 0; i < iterations; i++) {
    db.vendors.getPlanCache().clear();
    db.orders.getPlanCache().clear();
    timeout = startTimeout();
    time = db.vendors.explain("executionStats").aggregate([
      {
        $unwind: "$contacts"
      },
      {
        $project: {
          _id: 0,
          entityType: "Vendor",
          entityId: "$_id",
          entityName: "$name",
          contactType: "$contacts.type.value",
          value: "$contacts.value"
        }
      },
      {
        $unionWith: {
          coll: "orders",
          pipeline: [
            {
              $unwind: "$contacts"
            },
            {
              $project: {
                _id: 0,
                entityType: "Order",
                entityId: "$_id",
                entityName: { $concat: ["$customer.person.firstName", " ", "$customer.person.lastName"] },
                contactType: "$contacts.type.value",
                value: "$contacts.value"
              }
            }
          ]
        },
      },
      {
        $sort: {
          entityId: 1,
          contactType: 1
        }
      }
    ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('6', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('6', -1, -1);
  log(e);
}
log('Finished testing query 6');

// 7. Intersection

log('Started testing query 7');
try {
  for (let i = 0; i < iterations; i++) {
    db.tags.getPlanCache().clear();
    time = db.tags.find({
      $and: [
        { interestedPeople: { $exists: true, $ne: [] } },
        { postsTagged: { $exists: true, $ne: [] } }
      ]
    }, {
      commonTag: "$value"
    }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('7', i, time);
  }
} catch (e) {
  recordStats('7', -1, -1);
  log(e);
}
log('Finished testing query 7');

// 8. Difference

// 8.1 Using Lookup (not recommended for large datasets)

log('Started testing query 8.1');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    db.orders.getPlanCache().clear();
    timeout = startTimeout();
    time = db.persons.explain("executionStats").aggregate([
      {
        $lookup: {
          from: "orders",
          localField: "_id",
          foreignField: "customer.person.personId",
          as: "orders"
        }
      },
      {
        $match: {
          orders: { $eq: [] }
        }
      },
      {
        $project: {
          firstName: 1,
          lastName: 1,
        }
      }
    ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('8.1', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('8.1', -1, -1);
  log(e);
}
log('Finished testing query 8.1');

// 8.2 Without Lookup

log('Started testing query 8.2');
try {
  for (let i = 0; i < iterations; i++) {
    db.persons.getPlanCache().clear();
    time = db.persons.find({
      customer: { $exists: false }
    }, {
      firstName: 1,
      lastName: 1
    }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('8.2', i, time);
  }
} catch (e) {
  recordStats('8.2', -1, -1);
  log(e);
}
log('Finished testing query 8.2');

// 9. Sorting

// 9.1 Non-Indexed Attributes

log('Started testing query 9.1');
try {
  for (let i = 0; i < iterations; i++) {
    db.products.getPlanCache().clear();
    time = db.products.find().sort({ brand: 1 }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('9.1', i, time);
  }
} catch (e) {
  recordStats('9.1', -1, -1);
  log(e);
}
log('Finished testing query 9.1');

// 9.2 Indexed Attributes

log('Started testing query 9.2');
try {
  for (let i = 0; i < iterations; i++) {
    db.products.getPlanCache().clear();
    time = db.products.find().sort({ _id: 1 }).maxTimeMS(maxTimeMS).explain("executionStats").executionStats.executionTimeMillis / 1000;
    recordStats('9.2', i, time);
  }
} catch (e) {
  recordStats('9.2', -1, -1);
  log(e);
}
log('Finished testing query 9.2');

// 10. Distinct

log('Started testing query 10');
try {
  for (let i = 0; i < iterations; i++) {
    db.vendors.getPlanCache().clear();
    timeout = startTimeout();
    time = db.vendors.explain("executionStats").aggregate([
      {
        $unwind: "$manufacturesProducts"
      },
      {
        $group: {
          _id: {
            brand: "$manufacturesProducts.brand",
            country: "$country"
          }
        }
      },
      {
        $project: {
          _id: 0,
          brand: "$_id.brand",
          country: "$_id.country"
        }
      },
      {
        $sort: {
          brand: 1,
          country: 1
        }
      },
    ]).stages[0]["$cursor"].executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('10', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('10', -1, -1);
  log(e);
}
log('Finished testing query 10');

// 11. MapReduce

log('Started testing query 11');
try {
  for (let i = 0; i < iterations; i++) {
    db.orders.getPlanCache().clear();
    timeout = startTimeout();
    time = db.orders.explain("executionStats").aggregate([
      {
        $group: {
          _id: "$customer.customerId",
          orderCount: { $sum: 1 }
        }
      }
    ]).executionStats.executionTimeMillis / 1000;
    clearTimeout(timeout);
    recordStats('11', i, time);
  }
} catch (e) {
  clearTimeout(timeout);
  recordStats('11', -1, -1);
  log(e);
}
log('Finished testing query 11');
