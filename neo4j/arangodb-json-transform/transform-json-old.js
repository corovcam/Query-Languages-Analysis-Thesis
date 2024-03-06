const fs = require('fs');
const path = require('path');
const json = require('big-json');

// const vendors = require("./exports/vendors.json");
// const products = require("./exports/products.json");

function streamFilesInDirectory(dirname, onFileStream, onError) {
  fs.readdir(dirname, function(err, filenames) {
    if (err) {
      onError(err);
      return;
    }
    filenames.forEach(function(filename) {
      if (!filename.endsWith('.json')) return;
      const fileReadStream = fs.createReadStream(dirname + filename, 'utf-8');
      const outWriteStream = fs.createWriteStream(`./exports/transformed/nodes/${filename}`, 'utf-8');
      return onFileStream(filename, fileReadStream, outWriteStream);
    });
  });
}

streamFilesInDirectory('./exports/nodes/', function(filename, readStream, writeStream) {
  const parseStream = json.createParseStream();
  // const transformed = [];

  parseStream.on('data', function(doc) {
    console.log(`[${new Date().toISOString()}]\tTransforming ${filename} nodes to ArangoDB format.`);
    // console.log(doc);
    const node = Object.values(doc)[0];
    const newDoc = { _key: node.id.toString(), ...node?.properties };
    // transformed.push(newDoc);
    writeStream.write(JSON.stringify(newDoc) + '\n');
  });

  parseStream.on('end', function() {
    writeStream.destroy(true);
    console.log(`[${new Date().toISOString()}]\tFinished transforming ${filename} nodes to ArangoDB format.`);
  });

  readStream.pipe(parseStream);
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

// streamFilesInDirectory('./exports/edges/', function(filename, readStream) {
//   console.log(`[${new Date().toISOString()}]\tTransforming ${filename} edges to ArangoDB format.`);

//   const parseStream = json.createParseStream();

//   parseStream.on('data', function(pojo) {
//       // => receive reconstructed POJO
//   });

//   readStream.pipe(parseStream);

//   const edges = JSON.parse(readStream);
//   // const collNames = Object.keys(edges[0])[0].split("_");
//   // const fromColl = collNames[0];
//   // const toColl = collNames[1];
//   const transformed = [];
//   for (const doc of edges) {
//     const rel = Object.values(doc)[0];
//     const newDoc = {
//       _from: `${rel.start.labels[0].toLowerCase()}s/${rel.start.id}`,
//       _to: `${rel.end.labels[0].toLowerCase()}s/${rel.end.id}`,
//       rel: {...rel?.properties}
//     };
//     transformed.push(newDoc);
//   }
//   fs.writeFileSync(`./exports/transformed/edges/${filename}`, JSON.stringify(transformed));
//   console.log(`[${new Date().toISOString()}]\tFinished transforming ${filename} edges to ArangoDB format.`);
// }, function(err) {
//   throw err;
// });

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