import { createWriteStream, WriteStream, mkdirSync } from "fs";
import { DataStream, MapCallback } from "scramjet";
import { CustomLogger as logger } from "./utils";
import { ARRAY_MAX_ALLOWED_LENGTH } from "./constants";

export function mapAndDumpStream(
  stream: DataStream,
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

  return stream
    .map(mapCallback)
    .join('\n')
    // .batch(ARRAY_MAX_ALLOWED_LENGTH) // we batch the data by default 65535 records
    // .flatten()
    .catch(console.error)
    .pipe(
      outputFileStream
      .on("error", console.error)
      .on("end", () =>{
        logger.info(`Finished generating ${entityCount} records of type ${entityType}.`)}
      )
    )
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
//       .catch(console.error)
//       .pipe(outputFileStream)
//       .on("error", console.error)
//       .on("end", () =>{
//         outputFileStream.write(";\n");
//         outputFileStream.close();
//         logger.info(`Finished generating ${entityCount} records of type ${entityType}.`)}
//       );
//   }
// }

// module.exports = { DataStream }
