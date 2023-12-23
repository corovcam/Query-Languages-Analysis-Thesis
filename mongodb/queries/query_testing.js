const fs = require("fs");

const iterations = 20;
const recordVolume = 4000;
const stats = [['db', 'record_volume', 'query', 'iteration', 'time_in_seconds']];
let time;

// Helper function to record query stats
function recordStats(queryName, iteration, time) {
  stats.push(['mongodb', recordVolume, queryName, iteration, time]);
}

// Set cursor (query) timeout to 5 minutes
db.adminCommand( { setParameter: 1, cursorTimeoutMillis: 300000 } );

// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Attributes
for (let i = 0; i < iterations; i++) {
  db.vendors.getPlanCache().clear();
  time = db.vendors.find({ name: "Bauch - Denesik" }, { name: 1 }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('1.1', i, time);
}

// 1.2 Non-Indexed Attributes - Range Query

// Drop index on birthday attribute if exists
db.persons.dropIndex({ birthday: 1 });

for (let i = 0; i < iterations; i++) {
  db.persons.getPlanCache().clear();
  time = db.persons.find({ birthday: { $gte: ISODate('1980-01-01'), $lte: ISODate('1990-12-31') } }, { firstName: 1, lastName: 1, birthday: 1 }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('1.2', i, time);
}

// 1.3 Indexed Attributes

for (let i = 0; i < iterations; i++) {
  db.vendors.getPlanCache().clear();
  time = db.vendors.find({ _id: 24 }, { name: 1 }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('1.3', i, time);
}

// 1.4 Indexed Attributes - Range Query

// Create index on birthday attribute
db.persons.createIndex({ birthday: 1 });

for (let i = 0; i < iterations; i++) {
  db.persons.getPlanCache().clear();
  time = db.persons.find({ birthday: { $gte: ISODate('1980-01-01'), $lte: ISODate('1990-12-31') } }, { firstName: 1, lastName: 1, birthday: 1 }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('1.4', i, time);
}

// 2. Aggregation

// 2.1 COUNT

for (let i = 0; i < iterations; i++) {
  db.products.getPlanCache().clear();
  time = db.products.explain("executionStats").aggregate([{ $group: { _id: "$brand", productCount: { $sum: 1 } } }]).executionStats.executionTimeMillis / 1000;
  recordStats('2.1', i, time);
}

// 2.2 MAX

for (let i = 0; i < iterations; i++) {
  db.products.getPlanCache().clear();
  time = db.products.explain("executionStats").aggregate([{ $group: { _id: "$brand", maxPrice: { $max: "$price" } } }]).executionStats.executionTimeMillis / 1000;
  recordStats('2.2', i, time);
}

// 3. Join ( TODO: One complex JOIN in mongoDB)

// 3.1 Non-Indexed Attributes

for (let i = 0; i < iterations; i++) {
  db.types.getPlanCache().clear();
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
  recordStats('3.1', i, time);
}

// 3.2 Indexed Attributes

for (let i = 0; i < iterations; i++) {
  db.products.getPlanCache().clear();
  time = db.products.find().explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('3.2', i, time);
}

// 3.3 Complex Join 1

// Complex query with "lookup" to retrieve order details

// TODO: Not working at the moment, cause "vendor" is not embedded in "orders.containsProducts" array
// db.orders.find();

// Need to join "vendors" and "orders" on "containsProducts.productId" and "manufacturesProducts.productId" respectively
for (let i = 0; i < iterations; i++) {
  db.orders.getPlanCache().clear();
  db.vendors.getPlanCache().clear();
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
  recordStats('3.3', i, time);
}

// 3.4 Complex Join 2 (having more than 1 friend)

// Follower Count (not both way friendship)
// TODO: Look for possible optimizations... maybe embed whole Person object in knowsPeople array
for (let i = 0; i < iterations; i++) {
  db.persons.getPlanCache().clear();
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
  recordStats('3.4', i, time);
}

// 4. Unlimited Traversal

// 4.1 Find all direct and indirect relationships between people up to 4 (0, 1, 2, 3) levels deep

for (let i = 0; i < iterations; i++) {
  db.persons.getPlanCache().clear();
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
  recordStats('4.1', i, time);
}

// 4.2 Find the shortest path between two persons using $graphLookup

for (let i = 0; i < iterations; i++) {
  db.persons.getPlanCache().clear();
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
  recordStats('4.2', i, time);
}

// 5. Optional Traversal

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
  }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('5', i, time);
}

// 6. UNION

for (let i = 0; i < iterations; i++) {
  db.vendors.getPlanCache().clear();
  db.orders.getPlanCache().clear();
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
  recordStats('6', i, time);
}

// 7. Intersection

for (let i = 0; i < iterations; i++) {
  db.tags.getPlanCache().clear();
  time = db.tags.find({
    $and: [
      { interestedPeople: { $exists: true, $ne: [] } },
      { postsTagged: { $exists: true, $ne: [] } }
    ]
  }, {
    commonTag: "$value"
  }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('7', i, time);
}

// 8. Difference

// 8.1 Using Lookup (not recommended for large datasets)

for (let i = 0; i < iterations; i++) {
  db.persons.getPlanCache().clear();
  db.orders.getPlanCache().clear();
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
  recordStats('8.1', i, time);
}

// 8.2 Without Lookup

for (let i = 0; i < iterations; i++) {
  db.persons.getPlanCache().clear();
  time = db.persons.find({
    customer: { $exists: false }
  }, {
    firstName: 1,
    lastName: 1
  }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('8.2', i, time);
}

// 9. Sorting

// 9.1 Non-Indexed Attributes

for (let i = 0; i < iterations; i++) {
  db.products.getPlanCache().clear();
  time = db.products.find().sort({ brand: 1 }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('9.1', i, time);
}

// 9.2 Indexed Attributes

for (let i = 0; i < iterations; i++) {
  db.products.getPlanCache().clear();
  time = db.products.find().sort({ _id: 1 }).explain("executionStats").executionStats.executionTimeMillis / 1000;
  recordStats('9.2', i, time);
}

// 10. Distinct

for (let i = 0; i < iterations; i++) {
  db.vendors.getPlanCache().clear();
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
  recordStats('10', i, time);
}

// 11. MapReduce

for (let i = 0; i < iterations; i++) {
  db.orders.getPlanCache().clear();
  time = db.orders.explain("executionStats").aggregate([
    {
      $group: {
        _id: "$customer.customerId",
        orderCount: { $sum: 1 }
      }
    }
  ]).executionStats.executionTimeMillis / 1000;
  recordStats('11', i, time);
}

// Write results to CSV
const csv = stats.map(row => row.join(',')).join('\n');
fs.writeFileSync(`logs/queries/results_${Date.now()}.csv`, csv, "utf8");
