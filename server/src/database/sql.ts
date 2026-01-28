import fs from 'node:fs/promises';

import type { DbClient } from './connection';

const splitStatements = (sql: string) =>
  sql
    .split(';')
    .map((statement) => statement.trim())
    .filter((statement) => statement.length > 0);

export const executeSqlFile = async (db: DbClient, filePath: string) => {
  const sql = await fs.readFile(filePath, 'utf8');
  const statements = splitStatements(sql);
  for (const statement of statements) {
    await db.run(statement);
  }
};
