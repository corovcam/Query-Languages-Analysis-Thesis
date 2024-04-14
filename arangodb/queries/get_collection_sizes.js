const { db, aql } = require("@arangodb");
const fs = require("fs");

let colls = db._collections();
let coll_sizes = {};
let sum = 0;
const logs_file = `logs/collection_sizes_${Date.now()}.log`;

for (let coll of colls) {
  if (coll.name().startsWith("_")) continue;
  const documentsSize = coll.figures().documentsSize;
  coll_sizes[coll.name()] = documentsSize;
  sum += documentsSize;
}

fs.append(logs_file, "collection,size_in_bytes\n");
for (let coll in coll_sizes) {
  fs.append(logs_file, `${coll},${coll_sizes[coll]}\n`);
}
fs.append(logs_file, "\n");
fs.append(logs_file, `total,${sum}\n`);
