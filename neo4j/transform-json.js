const fs = require('fs');

const vendors = require("./exports/vendors.json");
const products = require("./exports/products.json");
const rels = require("./exports/vendor_products.json");

for (const coll of [vendors, products]) {
  const transformed = [];
  for (const doc of coll) {
    const node = Object.values(doc)[0];
    const newDoc = { _key: node.id.toString(), ...node.properties };
    transformed.push(newDoc);
  }
  const fileName = Object.keys(coll[0])[0];
  fs.writeFileSync(`./exports/transformed/${fileName}.json`, JSON.stringify(transformed));
}

const transformed = [];
for (const doc of rels) {
  const rel = Object.values(doc)[0];
  const newDoc = {
    _from: `vendor/${rel.start.id}`,
    _to: `product/${rel.end.id}`,
    // @ts-ignore
    ...rel.properties
  };
  transformed.push(newDoc);
}
transformed && fs.writeFileSync(`./exports/transformed/rels.json`, JSON.stringify(transformed));