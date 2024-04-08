import { createWriteStream } from "fs";
import { DataStream, MapCallback } from "scramjet";
import { CustomLogger as logger, isNumber } from "./utils";

// Stream transformer functions

export function mapToSQLDump(row: (string | number)[]) {
  const valuesString = row
    .map((value) => {
      if (isNumber(value)) {
        return value;
      } else if (typeof value === "string") {
        return `'${value}'`; // Escape single quotes (MySQL, SQLite require single quotes for strings)
      } else {
        return `'${value.toString()}'`;
      }
    })
    .join(", ");
  return `(${valuesString})`;
}

export function mapToCSV(row: (string | number)[]) {
  const valuesString = row
    .map((value) => {
      if (isNumber(value)) {
        return value;
      } else if (typeof value === "string") {
        return `'${value}'`; // Escape single quotes (MySQL, SQLite require single quotes for strings)
      } else {
        return `'${value.toString()}'`;
      }
    })
    .join(",");
  return valuesString;
}

// Stream transformation and dumping functions

export function mapAndDump(
  streamOrArray: DataStream | any[],
  mapCallback: MapCallback,
  entityType: string,
  entityCount: number = null,
  outputFilePath: string,
  preamble?: string
): Promise<void> {
  const outputFileStream = createWriteStream(outputFilePath);
  if (preamble) {
    outputFileStream.write(preamble + "\n");
  }

  let stream: DataStream;
  if (Array.isArray(streamOrArray)) {
    stream = DataStream.from(streamOrArray);
  } else {
    stream = streamOrArray;
  }

  return new Promise<void>((resolve, reject) => {
    stream
      .map(mapCallback)
      .join("\n")
      .catch(logger.error)
      .pipe(outputFileStream)
      .on("error", (e) => {
        logger.error(e);
        reject(e);
      })
      .on("close", () => {
        entityCount
          ? logger.info(
              `Written ${entityCount} records of type ${entityType} to ${outputFilePath}.`
            )
          : logger.info(
              `Finished writing records of type ${entityType} to ${outputFilePath}.`
            );
        resolve();
      });
  });
}

/**
 * Used for dumping stream of JSON objects to a file. Can be used for future denormalization into various data models, e.g. Cassandra.
 */
export function mapAndDumpJSONLines(
  stream: DataStream,
  outputFilePath: string,
  containsSet: boolean = false, // Optional
  mapCallback?: MapCallback
): Promise<void> {
  const outputFileStream = createWriteStream(outputFilePath);

  const mappedStream = mapCallback ? stream.map(mapCallback) : stream;

  const JSONStringifiedStream = containsSet
    ? mappedStream
        .toStringStream((obj) =>
          JSON.stringify(obj, (_key, value) =>
            value instanceof Set ? [...value] : value
          )
        )
        .append("\n")
    : mappedStream.JSONStringify("\n");

  return new Promise<void>((resolve, reject) => {
    JSONStringifiedStream.catch(logger.error)
      .pipe(outputFileStream)
      .on("error", (e) => {
        logger.error(e);
        reject(e);
      })
      .on("close", () => {
        logger.info(`Finished writing to ${outputFilePath}.`);
        resolve();
      });
  });
}
