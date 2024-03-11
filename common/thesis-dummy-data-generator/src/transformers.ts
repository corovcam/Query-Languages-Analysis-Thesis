import { createWriteStream } from "fs";
import { DataStream, MapCallback } from "scramjet";
import { CustomLogger as logger } from "./utils";
import { ARRAY_MAX_ALLOWED_LENGTH } from "./constants";

export function mapToSQLDump(row: (string | number)[]) {
  const valuesString = row
    .map((value) => {
      if (typeof value === "string") {
        return `'${value}'`;
      } else if (typeof value === "number") {
        return value;
      }
      return value;
    })
    .join(", ");
  return `(${valuesString})`;
}
