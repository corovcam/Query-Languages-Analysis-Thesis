import { createReadStream, readdir, createWriteStream, mkdirSync } from 'fs';
import { pipeline } from 'stream';
import split2 from 'split2';

async function* processJSONChunkOfNodes(stream) {
  for await (const nodeObj of stream) {
    const node = Object.values(nodeObj)[0];
    const newDoc = { _key: node.id.toString(), ...node?.properties };
    yield JSON.stringify(newDoc) + '\n';
  }
}

async function* processJSONChunkOfEdges(stream) {
  for await (const edgeObj of stream) {
    const rel = Object.values(edgeObj)[0];
    const newDoc = {
      _from: `${rel.start.labels[0].toLowerCase()}s/${rel.start.id}`,
      _to: `${rel.end.labels[0].toLowerCase()}s/${rel.end.id}`,
      rel: {...rel?.properties}
    };
    yield JSON.stringify(newDoc) + '\n';
  }
}

function streamFilesInDirectory(dirname, outDirName, processJSONChunk, onError) {
  readdir(dirname, function(err, filenames) {
    if (err) {
      onError(err);
      return;
    }
    filenames.forEach(function(filename) {
      if (!filename.endsWith('.json')) return;

      mkdirSync(outDirName, { recursive: true });

      const readStream = createReadStream(dirname + filename, 'utf8');
      const writeStream = createWriteStream(outDirName + filename, 'utf8');

      console.log(`[${new Date().toISOString()}]\tTransforming ${filename} to ArangoDB format.`);
      pipeline(readStream, split2(JSON.parse), processJSONChunk, writeStream, 
        (err) => { 
          if (err) {
            onError(err);
          } else {
            console.log(`[${new Date().toISOString()}]\tFinished transforming ${filename} to ArangoDB format.`);
          }
      });
    });
  });
}

const currentTime = new Date().toISOString().replace(/:/g, '-');
const onError = (err) => { console.error(err); };
streamFilesInDirectory('./exports/nodes/', `./exports/transformed_${currentTime}/nodes/`, processJSONChunkOfNodes, onError);
streamFilesInDirectory('./exports/edges/', `./exports/transformed_${currentTime}/edges/`, processJSONChunkOfEdges, onError);
