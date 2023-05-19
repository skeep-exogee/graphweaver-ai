import fs from "fs";

function findTablesInSQLDump(sqlDump: string): string[] {
  const createTableRegex = /CREATE TABLE\s+(public\.\w+)\s*\([\s\S]+?\);/g;
  let match;
  const tables: string[] = [];

  while ((match = createTableRegex.exec(sqlDump)) !== null) {
    const createTableStatement = match[0];
    tables.push(createTableStatement);
  }

  return tables;
}

function readSQLDumpFile(filePath: string): string {
  return fs.readFileSync(filePath, "utf-8");
}

// Usage example

export const getTables = () => {
  const filePath = "./src/datasources/dump.sql";
  const sqlDump = readSQLDumpFile(filePath);
  return findTablesInSQLDump(sqlDump);
};
