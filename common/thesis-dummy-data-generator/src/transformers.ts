import { CustomLogger as logger, isNumber } from "./utils";

// Mappers

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

export function mapToCSV(row: (string | number)[]) {
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
    .join(',');
  return valuesString;
}