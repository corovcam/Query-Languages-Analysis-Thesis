import { createReadStream, readdir, createWriteStream, mkdirSync } from 'fs';
import { pipeline } from 'stream';
import split2 from 'split2';

export function streamFilesInDirectory(dirname, outDirName, processJSONChunk, onError) {
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
