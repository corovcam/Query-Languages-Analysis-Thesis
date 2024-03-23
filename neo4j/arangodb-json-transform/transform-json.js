import { streamFilesInDirectory } from './streamer.js';

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

const currentTime = new Date().toISOString().replace(/:/g, '-');
const onError = (err) => { console.error(err); };
streamFilesInDirectory('./exports/nodes/', `./exports/transformed_${currentTime}/nodes/`, processJSONChunkOfNodes, onError);
streamFilesInDirectory('./exports/edges/', `./exports/transformed_${currentTime}/edges/`, processJSONChunkOfEdges, onError);
