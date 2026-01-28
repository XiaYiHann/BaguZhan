import path from 'node:path';

import { openDatabase } from './connection';
import { executeSqlFile } from './sql';

const run = async () => {
  const db = openDatabase();
  try {
    const seedPath = path.join(__dirname, 'sql', 'seed.sql');
    await executeSqlFile(db, seedPath);
    console.log('种子数据写入完成');
  } finally {
    await db.close();
  }
};

run().catch((error) => {
  console.error('种子数据写入失败', error);
  process.exit(1);
});
