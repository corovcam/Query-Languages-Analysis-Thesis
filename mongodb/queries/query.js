console.log("db.vendors.find();")
db.vendors.find()

console.log(`
db.vendors.find({
  "vendorId": 1
})
`)
db.vendors.find({
  "vendorId": 1
})

console.log(`db.vendors.find({ $or: [{ vendorId: 1 }, { vendorId: 2 }] })`)
db.vendors.find({ $or: [{ vendorId: 1 }, { vendorId: 2 }] })

console.log(`db.vendors.find({ $or: [{ vendorId: 1 }, { vendorId: 2 }] })`)
db.vendors.find({ $or: [{ vendorId: 1 }, { vendorId: 2 }] })