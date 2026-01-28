import path from 'node:path';

import { openDatabase } from './connection';
import { executeSqlFile } from './sql';

const run = async () => {
  const db = openDatabase();
  try {
    const schemaPath = path.join(__dirname, 'sql', 'schema.sql');
    await executeSqlFile(db, schemaPath);
    console.log('数据库迁移完成');
  } finally {
    await db.close();
  }
};

run().catch((error) => {
  console.error('数据库迁移失败', error);
  process.exit(1);
});
