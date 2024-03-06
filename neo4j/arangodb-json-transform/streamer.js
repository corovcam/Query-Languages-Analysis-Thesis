const fs = require('fs');
const readline = require('readline');

function createReadLineStream(filePath, fileName, processJSONChunk) {
  const CHUNK_SIZE = 1000;
  let chunks = [];

  const readStream = fs.createReadStream(filePath, 'utf8');
  //Created stream of the json
  const rl = readline.createInterface({
    input: readStream,
    crlfDelay: Infinity
  });

  //below fn will run whenever we get the data from stream
  rl.on('line', (line) => {
    if (line) {
      chunks.push(line);
      if (chunks.length >= CHUNK_SIZE) {
        //once chunks lenght is 65536 we are pausing the stream. this will trigger the below on.pause event.
        rl.pause();
      }
    }
  });

  rl.on('pause', async () => {
    await processJSONChunk(fileName, chunks);
    chunks.length = 0;
    setTimeout(() => rl.resume(), 5 * 1000);
  });

  rl.on('close', async () => {
    await processJSONChunk(fileName, chunks);
  });

  return rl;
}

function streamFilesInDirectory(dirname, processJSONChunk, onError) {
  fs.readdir(dirname, function(err, filenames) {
    if (err) {
      onError(err);
      return;
    }
    filenames.forEach(function(filename) {
      if (!filename.endsWith('.json')) return;
      createReadLineStream(dirname + filename, filename, processJSONChunk);
    });
  });
}

module.exports = { streamFilesInDirectory };
