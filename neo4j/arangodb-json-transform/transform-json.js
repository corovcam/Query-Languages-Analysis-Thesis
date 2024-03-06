const fs = require('fs');
const { streamFilesInDirectory } = require('./streamer');

const processJSONChunkOfNodes = async (fileName, chunks) => {
  console.log(`[${new Date().toISOString()}]\tTransforming ${chunks.length} of ${fileName} nodes to ArangoDB format.`);
  const transformed = [];
  for (const chunk of chunks) {
    const node = Object.values(JSON.parse(chunk))[0];
    const newDoc = { _key: node.id.toString(), ...node?.properties };
    transformed.push(JSON.stringify(newDoc));
  }
  fs.appendFileSync(`./exports/transformed/nodes/${fileName}`, transformed.join('\n') + '\n');
  console.log(`[${new Date().toISOString()}]\tFinished transforming ${chunks.length} of ${fileName} nodes to ArangoDB format.`);
}

const processJSONChunkOfEdges = async (fileName, chunks) => {
  console.log(`[${new Date().toISOString()}]\tTransforming ${chunks.length} of ${fileName} edges to ArangoDB format.`);
  const transformed = [];
  for (const chunk of chunks) {
    const rel = Object.values(JSON.parse(chunk))[0];
    const newDoc = {
      _from: `${rel.start.labels[0].toLowerCase()}s/${rel.start.id}`,
      _to: `${rel.end.labels[0].toLowerCase()}s/${rel.end.id}`,
      rel: {...rel?.properties}
    };
    transformed.push(JSON.stringify(newDoc));
  }
  fs.appendFileSync(`./exports/transformed/edges/${fileName}`, transformed.join('\n') + '\n');
  console.log(`[${new Date().toISOString()}]\tFinished transforming ${chunks.length} of ${fileName} edges to ArangoDB format.`);
}

streamFilesInDirectory('./exports/nodes/', processJSONChunkOfNodes, (err) => { throw err; });

streamFilesInDirectory('./exports/edges/', processJSONChunkOfEdges, (err) => { throw err; });
