import { createWriteStream, WriteStream, mkdirSync } from "fs";
import { DataStream, MapCallback, StringStream } from "scramjet";
import { CustomLogger as logger } from "./utils";
import { ARRAY_MAX_ALLOWED_LENGTH } from "./constants";

export function mapAndDump(
  streamOrArray: DataStream | any[],
  mapCallback: MapCallback,
  entityType: string,
  entityCount: number,
  outputFilePath: string,
  preamble?: string,
): WriteStream {
  const outputFileStream = createWriteStream(outputFilePath);
  if (preamble) {
    outputFileStream.write(preamble + '\n');
  }

  let stream: DataStream;
  if (Array.isArray(streamOrArray)) {
    stream = DataStream.from(streamOrArray);
  } else {
    stream = streamOrArray;
  }

  return stream
    .map(mapCallback)
    .join('\n')
    .catch(logger.error)
    .pipe(outputFileStream)
    .on("error", logger.error)
    .on("finish", () => { logger.info(`Written ${entityCount} records of type ${entityType} to ${outputFilePath}.`); });
}

export function mapAndDumpJSONLines(
  stream: DataStream,
  outputFilePath: string,
  containsSet: boolean = false, // Optional
  mapCallback?: MapCallback, // Optional
): WriteStream {
  const outputFileStream = createWriteStream(outputFilePath);

  const mappedStream = mapCallback ? stream.map(mapCallback) : stream;

  const JSONStringifiedStream = containsSet ? 
    mappedStream.toStringStream((obj) => JSON.stringify(obj, (_key, value) => (value instanceof Set ? [...value] : value))).append('\n')
    : mappedStream.JSONStringify('\n');

  return JSONStringifiedStream
    .catch(logger.error)
    .pipe(outputFileStream)
    .on("error", logger.error)
    .on('finish', () => { logger.info(`Finished writing to ${outputFilePath}.`); });
}

// const DataStream = {
//   mapAndDumpStream(
//     mapCallback: MapCallback,
//     entityType: string,
//     entityCount: number,
//     outputFilePath: string,
//     preamble?: string,
//   ) {
//     const outputFileStream = createWriteStream(outputFilePath);
//     if (preamble) {
//       outputFileStream.write(preamble + '\n');
//     }
//     const self = this as DataStreamType;
//     return self
//       .map(mapCallback)
//       .batch(ARRAY_MAX_ALLOWED_LENGTH) // we batch the data by default 65535 records
//       .join('')
//       .catch(logger.error)
//       .pipe(outputFileStream)
//       .on("error", logger.error)
//       .on("end", () =>{
//         outputFileStream.write(";\n");
//         outputFileStream.close();
//         logger.info(`Finished generating ${entityCount} records of type ${entityType}.`)}
//       );
//   }
// }

// module.exports = { DataStream }
