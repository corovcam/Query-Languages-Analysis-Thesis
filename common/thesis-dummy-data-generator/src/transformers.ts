export function mapToSQLDump(dataObj: object, tableName: string, columns: string[]) {
    const columnsString = columns.join(", ");
    const values = Object.values(dataObj);
    const valuesString = values.map(value => {
        if (typeof value === "string") {
            return `'${value}'`;
        } else if (typeof value === "number") {
            return value;
        }
        return value;
    }).join(", ");
    return `INSERT INTO ${tableName} (${columnsString}) VALUES (${valuesString});\n`;
}