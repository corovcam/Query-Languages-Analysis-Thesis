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
  }
]);

// 3.2 Indexed Attributes


db.products.find();

// db.products.aggregate([
//   {
//     $lookup: {
//       from: "orders",
//       localField: "_id",
//       foreignField: "containsProducts.product.productId",
//       as: "orderProducts"
//     }
//   },
//   {
//     $project: {
//       asin: 1,
//       brand: 1,
//       imageUrl: 1,
//       price: 1,
//       title: 1,
//       "orderProducts._id": 1,
//       "orderProducts.containsProducts.quantity": 1,
//     }
//   }
// ]);

// 3.3 Complex Join 1

db.orders.aggregate([
  {
    $lookup: {
      from: "vendors",
      localField: "containsProducts.product.productId",
      foreignField: "products.productId",
      as: "ordersWithProductVendors"
    }
  },
  {
    $project: {
      _id: 1,
      customerId: 1,
      "ordersWithProductVendors._id": 1,
      "ordersWithProductVendors.name": 1,
      "ordersWithProductVendors.country": 1,
      "containsProducts.product._id": 1,
      "containsProducts.product.asin": 1,
      "containsProducts.product.brand": 1,
      "containsProducts.product.imageUrl": 1,
      "containsProducts.product.price": 1,
      "containsProducts.product.title": 1,
      "containsProducts.quantity": 1,
    }
  }
]);

// 3.4 Complex Join 2 (having more than 1 friend)
