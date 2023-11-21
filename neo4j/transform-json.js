const fs = require('fs');

// const vendors = require("./exports/vendors.json");
// const products = require("./exports/products.json");

function readFiles(dirname, onFileContent, onError) {
  fs.readdir(dirname, function(err, filenames) {
    if (err) {
      onError(err);
      return;
    }
    filenames.forEach(function(filename) {
      if (!filename.endsWith('.json')) return;
      fs.readFile(dirname + filename, 'utf-8', function(err, content) {
        if (err) {
          onError(err);
          return;
        }
        onFileContent(filename, content);
      });
    });
  });
}

readFiles('./exports/nodes/', function(filename, content) {
  const coll = JSON.parse(content);
  const transformed = [];
  for (const doc of coll) {
    const node = Object.values(doc)[0];
    const newDoc = { _key: node.id.toString(), ...node?.properties };
    transformed.push(newDoc);
  }
  // const fileName = Object.keys(coll[0])[0];
  fs.writeFileSync(`./exports/transformed/nodes/${filename}`, JSON.stringify(transformed));
}, function(err) {
  throw err;
});

// for (const coll of [vendors, products]) {
//   const transformed = [];
//   for (const doc of coll) {
//     const node = Object.values(doc)[0];
//     const newDoc = { _key: node.id.toString(), ...node.properties };
//     transformed.push(newDoc);
//   }
//   const fileName = Object.keys(coll[0])[0];
//   fs.writeFileSync(`./exports/transformed/${fileName}.json`, JSON.stringify(transformed));
// }

// const rels = require("./exports/vendor_products.json");

readFiles('./exports/edges/', function(filename, content) {
  const edges = JSON.parse(content);
  // const collNames = Object.keys(edges[0])[0].split("_");
  // const fromColl = collNames[0];
  // const toColl = collNames[1];
  const transformed = [];
  for (const doc of edges) {
    const rel = Object.values(doc)[0];
    const newDoc = {
      _from: `${rel.start.labels[0].toLowerCase()}s/${rel.start.id}`,
      _to: `${rel.end.labels[0].toLowerCase()}s/${rel.end.id}`,
      rel: {...rel?.properties}
    };
    transformed.push(newDoc);
  }
  fs.writeFileSync(`./exports/transformed/edges/${filename}`, JSON.stringify(transformed));
}, function(err) {
  throw err;
});

// const rels = require("./exports/rels.json");

// const transformed = [];
// for (const doc of rels) {
//   const rel = Object.values(doc)[0];
//   const newDoc = {
//     _from: `${rel.start.labels[0].toLowerCase()}s/${rel.start.id}`,
//     _to: `${rel.end.labels[0].toLowerCase()}s/${rel.end.id}`,
//     ...rel?.properties
//   };
//   transformed.push(newDoc);
// }
// transformed && fs.writeFileSync(`./exports/transformed/rels.json`, JSON.stringify(transformed));