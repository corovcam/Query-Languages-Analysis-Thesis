// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Attributes

db.vendors.find({ name: "Vendor A" }, { name: 1 });

// 1.2 Non-Indexed Attributes - Range Query

// db.persons.find({ birthday: { $gte: new Date("1980-01-01"), $lte: new Date("1990-12-31") } }, { firstName: 1, lastName: 1, birthday: 1 });

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

// 3. Join ( TODO: One complex JOIN in mongoDB)

// 3.1 Non-Indexed Attributes

// Join vendorContacts and orderContacts on the type of contact (the same document)

// TODO: Should I embed orderContacts and vendorContacts in the same document?
// Or the point is to only use $lookup for joining collections?

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

// 3.2 Indexed Attributes

// Find all Products contained in Orders
db.products.find();

// 3.3 Complex Join 1

// Complex query with "lookup" to retrieve order details

// TODO: Not working at the moment, cause "vendor" is not embedded in "orders.containsProducts" array
// db.orders.find();

// Need to join "vendors" and "orders" on "containsProducts.productId" and "manufacturesProducts.productId" respectively
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

// 3.4 Complex Join 2 (having more than 1 friend)

// Follower Count (not both way friendship)
// TODO: Look for possible optimizations... maybe embed whole Person object in knowsPeople array
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
  // TODO: Embed whole Person obj in knowsPeople array ???
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

// Find all direct and indirect relationships between people
// TODO: How to traverse both ways? (not only from person1 to person2, but also from person2 to person1)
// Maybe create a a new attribute "knownBy"?
// https://stackoverflow.com/questions/43784935/mongodb-graphlookup-in-reverse-order

// This is only one way relationship traversal
db.persons.aggregate([
  {
    $graphLookup: {
      from: "persons",
      startWith: "$_id",
      connectFromField: "_id",
      connectToField: "knowsPeople",
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
      depth: "$relationships.depth"
    }
  },
  {
    $sort: {
      sourcePersonId: 1,
      depth: 1,
      relatedPersonId: 1
    }
  }
]);

// Find the shortest path between two persons using $graphLookup

// This one stops traverses in BFS until it finds the target person (not necessarily the shortest path)
// The target person in not included in the result
// TODO: Find better soluton for shortest path? Or maybe it does not exist?
// https://stackoverflow.com/questions/42333529/mongodb-node-js-and-shortest-path-function-any-option-available
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
      // maxDepth: 3,
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
db.persons.aggregate([
  {
    $project: {
      firstName: 1,
      lastName: 1,
      friendCount: { $cond: { if: { $isArray: "$knowsPeople" }, then: { $size: "$knowsPeople" }, else: 0 } }
    }
  }
]);

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
// TODO: Rewrite data model to explicitly use $setIntersection operator?
db.tags.aggregate([
  {
    $match: {
      interestedPeople: { $exists: true, $ne: [] },
      postsTagged: { $exists: true, $ne: [] },
    }
  },
  {
    $project: {
        commonTag: "$value",
    }
  }
]);

// 8. Difference

// TODO: Rewrite query to explicitly use $setDifference operator?
// Find people who have not made any orders

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
  // $group stage is used except of db.collection.distinct() method
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

// Find the number of orders per customer

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
