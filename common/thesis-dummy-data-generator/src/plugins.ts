import { createWriteStream } from "fs";
import { DataStream, MapCallback } from "scramjet";
import { CustomLogger as logger } from "./utils";

export function mapAndDump(
  streamOrArray: DataStream | any[],
  mapCallback: MapCallback,
  entityType: string,
  entityCount: number = null,
  outputFilePath: string,
  preamble?: string,
): Promise<void> {
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

  return new Promise<void>((resolve, reject) => {
    stream.map(mapCallback)
      .join('\n')
      .catch(logger.error)
      .pipe(outputFileStream)
      .on("error", (e) => {
        logger.error(e);
        reject(e);
      })
      .on("close", () => { 
        entityCount ? 
          logger.info(`Written ${entityCount} records of type ${entityType} to ${outputFilePath}.`) 
          : logger.info(`Finished writing records of type ${entityType} to ${outputFilePath}.`); 
        resolve();
      });
    }
  );
}

export function mapAndDumpJSONLines(
  stream: DataStream,
  outputFilePath: string,
  containsSet: boolean = false, // Optional
  mapCallback?: MapCallback, // Optional
): Promise<void> {
  const outputFileStream = createWriteStream(outputFilePath);

  const mappedStream = mapCallback ? stream.map(mapCallback) : stream;

  const JSONStringifiedStream = containsSet ? 
    mappedStream.toStringStream((obj) => JSON.stringify(obj, (_key, value) => (value instanceof Set ? [...value] : value))).append('\n')
    : mappedStream.JSONStringify('\n');

  return new Promise<void>((resolve, reject) => {
    JSONStringifiedStream
      .catch(logger.error)
      .pipe(outputFileStream)
      .on("error", (e) => {
        logger.error(e);
        reject(e);
      })
      .on('close', () => { 
        logger.info(`Finished writing to ${outputFilePath}.`);
        resolve();
      });
    }
  );
}
