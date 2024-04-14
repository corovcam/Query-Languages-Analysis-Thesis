// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Attributes

db.vendors.find({ name: "Vendor A" }, { name: 1 });

// 1.2 Non-Indexed Attributes - Range Query

// Drop index on birthday attribute if exists
db.persons.dropIndex({ birthday: 1 });

db.persons.find({ birthday: { $gte: ISODate('1980-01-01'), $lte: ISODate('1990-12-31') } }, { firstName: 1, lastName: 1, birthday: 1 });

// 1.3 Indexed Attributes

db.vendors.find({ _id: 1 }, { name: 1 });

// 1.4 Indexed Attributes - Range Query

// Create index on birthday attribute
db.persons.createIndex({ birthday: 1 });

db.persons.find({ birthday: { $gte: ISODate('1980-01-01'), $lte: ISODate('1990-12-31') } }, { firstName: 1, lastName: 1, birthday: 1 });

// 2. Aggregation

// 2.1 COUNT

db.products.aggregate([{ $group: { _id: "$brand", productCount: { $sum: 1 } } }]);

// 2.2 MAX

db.products.aggregate([{ $group: { _id: "$brand", maxPrice: { $max: "$price" } } }]);

// 3. Join

// 3.1 Non-Indexed Attributes

// Join vendorContacts and orderContacts on the type of contact (the same document)

// Query 3.1 hit the !BSONObj size not supported! error with `BSONObj size: 16806194 (0x1007132) is invalid. Size must be between 0 and 16793600(16MB)` with 256k volume import
// Solution could be not to embed both arrays in the same document, but to split them into separate documents and use $lookup to join them in the query and that is why we have two queries for 3.1 below

// < 256k volume experiments
db.types.aggregate([
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
]);

// >= 256k volume experiments
db.types.aggregate([
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
]);

// 3.2 Indexed Attributes

// Find all Products contained in Orders
db.products.find();

// 3.3 Complex Join 1

// Complex query with "lookup" to retrieve order details

// Cannot embed "vendor" in "orders.containsProducts" cause MongoDB Relational Migrator fails to migrate it (probably due to circular reference) - so the following query is not possible
// db.orders.find();

// Need to join "vendors" and "orders" on "containsProducts.productId" and "manufacturesProducts.productId" respectively
// < 256k volume experiments
db.orders.aggregate([
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
]);

/*
Enormous waiting time for MongoDB Relational Migrator to migrate orders.containsProducts array
  - Waiting time: almost 74 hours with 4 retries and various errors:
    - `java.io.EOFException: Can not read response from server. Expected to read 4 bytes, read 0 bytes before connection was unexpectedly lost.`
    - `java.net.SocketTimeoutException: Read timed out`
  - First run took 2 weeks, and the entire testing server froze (probably due to memory leak and unrestricted page swapping)
  - https://stackoverflow.com/questions/13950496/what-is-java-io-eofexception-message-can-not-read-response-from-server-expect
  - problem turned out to be in MySQL halting the connection unexpectedly
  - solution: remove orders.containsProducts array
*/
// >= 256k volume experiments
db.orders.aggregate([
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
]);

// 3.4 Complex Join 2 (having more than 1 friend)

// Follower Count (not both way friendship)
db.persons.aggregate([
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
]);

// 4. Unlimited Traversal

// 4.1 Find all direct and indirect relationships between people up to 4 (0, 1, 2, 3) levels deep

db.persons.aggregate([
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
]);

// 4.2 Find the shortest path between two persons using $graphLookup

// This one stops traverses in BFS until it finds the target person (not necessarily the shortest path)
// The target person in not included in the result
// The result set is not the same as in previous databases, but the path is included in the result
// It basically performs BFS until it finds the target person, stops and prints each visited node
// The backtracking is not possible in mongoDB, but can be done in application layer
db.persons.aggregate([
  {
    $match: {
      _id: 1
    }
  },
  {
    $graphLookup: {
      from: "persons",
      startWith: "$_id",
      connectFromField: "knowsPeople",
      connectToField: "_id",
      as: "relationships",
      // maxDepth: 3, // NOTE: if not set, it will run into `MongoServerError: $graphLookup reached maximum memory consumption` in 256k volume experiments
      depthField: "depth",
      restrictSearchWithMatch: {
        _id: { $ne: 10 }
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
]);

// 5. Optional Traversal

// Get a list of all people and their friend count (0 if they have no friends)
db.persons.find({}, {
  firstName: 1,
  lastName: 1,
  friendCount: {
    $cond: {
      if: { $isArray: "$knowsPeople" },
      then: { $size: "$knowsPeople" },
      else: 0
    }
  }
});

// 6. UNION

// Get a list of contacts (email and phone) for both vendors and customers

// Vendor contacts
db.vendors.aggregate([
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
  // Order contacts
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
]);

// 7. Intersection

// Find common tags between posts AND persons
// Since id arrays of postTags and personTags are embedded in "tags" collection
// we can just find tag object with non-empty arrays of both postTags and personTags
db.tags.find({
  $and: [
    { interestedPeople: { $exists: true, $ne: [] } },
    { postsTagged: { $exists: true, $ne: [] } }
  ]
}, {
  commonTag: "$value"
});


// 8. Difference

// Find people who have not made any orders

// 8.1 Using Lookup (not recommended for large datasets)

// All people
db.persons.aggregate([
  // Match with orders collection
  {
    $lookup: {
      from: "orders",
      localField: "_id",
      foreignField: "customer.person.personId",
      as: "orders"
    }
  },
  // Match only people with no orders
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
]);

// 8.2 Without Lookup

// Match only people with no customer attribute (and thus no orders)
db.persons.find({
  customer: { $exists: false }
}, {
  firstName: 1,
  lastName: 1
});

// 9. Sorting

// 9.1 Non-Indexed Attributes

db.products.find().sort({ brand: 1 });

// 9.2 Indexed Attributes

db.products.find().sort({ _id: 1 });

// 10. Distinct

// https://www.mongodb.com/docs/v7.0/reference/method/db.collection.distinct/
// Results must not be larger than the maximum BSON size.
// If your results exceed the maximum BSON size, use the aggregation pipeline to retrieve distinct values using
// the $group operator, as described in Retrieve Distinct Values with the Aggregation Pipeline.

// Find unique combinations of product brands and the countries of the vendors selling those products
db.vendors.aggregate([
  {
    $unwind: "$manufacturesProducts"
  },
  // $group stage is used instead of db.collection.distinct() method
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
]);

// 11. MapReduce

// Find the number of orders per customer (only those who have made at least 1 order)

// 11.1. Using the deprecated mapReduce() method:
// https://www.mongodb.com/docs/manual/reference/method/db.collection.mapReduce/#db.collection.mapreduce--
db.orders.mapReduce(
  "function() { emit(this.customer.customerId, 1); }",
  "function(key, values) { return Array.sum(values); }",
  {
    out: { inline: 1 },
  }
);

// 11.2. Using the simpler (this case at least), more efficient and recommended aggregation pipeline:
db.orders.aggregate([
  {
    $group: {
      _id: "$customer.customerId",
      orderCount: { $sum: 1 }
    }
  }
]);
