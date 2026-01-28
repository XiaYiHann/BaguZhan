import path from 'node:path';

import { openDatabase } from '../src/database/connection';
import { executeSqlFile } from '../src/database/sql';

export const setupTestDb = async () => {
  const db = openDatabase(':memory:');
  const schemaPath = path.join(__dirname, '../src/database/sql/schema.sql');
  const seedPath = path.join(__dirname, '../src/database/sql/seed.sql');
  await executeSqlFile(db, schemaPath);
  await executeSqlFile(db, seedPath);
  return db;
};
