import { createWriteStream } from "fs";
import { DataStream, MapCallback } from "scramjet";
import { CustomLogger as logger, isNumber } from "./utils";
import { ARRAY_MAX_ALLOWED_LENGTH } from "./constants";

export function mapToSQLDump(row: (string | number)[]) {
  const valuesString = row
    .map((value) => {
      if (isNumber(value)) {
        return value;
      } else if (typeof value === "string") {
        return `'${value}'`;
      } else {
        return `'${value.toString()}'`;
      }
    })
    .join(", ");
  return `(${valuesString})`;
}

export function mapToTSV(row: (string | number)[]) {
  const valuesString = row
    .map((value) => {
      if (isNumber(value)) {
        return value;
      } else if (typeof value === "string") {
        return `'${value}'`;
      } else {
        return `'${value.toString()}'`;
      }
    })
    .join('\t');
  return valuesString;
}