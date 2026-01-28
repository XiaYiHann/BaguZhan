import path from 'node:path';
import sqlite3 from 'sqlite3';

export type DbClient = {
  run: (sql: string, params?: unknown[]) => Promise<void>;
  get: <T = unknown>(sql: string, params?: unknown[]) => Promise<T | undefined>;
  all: <T = unknown>(sql: string, params?: unknown[]) => Promise<T[]>;
  close: () => Promise<void>;
};

const createClient = (db: sqlite3.Database): DbClient => {
  const run = (sql: string, params: unknown[] = []) =>
    new Promise<void>((resolve, reject) => {
      db.run(sql, params, (err) => {
        if (err) {
          reject(err);
          return;
        }
        resolve();
      });
    });

  const get = <T = unknown>(sql: string, params: unknown[] = []) =>
    new Promise<T | undefined>((resolve, reject) => {
      db.get(sql, params, (err, row) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(row as T | undefined);
      });
    });

  const all = <T = unknown>(sql: string, params: unknown[] = []) =>
    new Promise<T[]>((resolve, reject) => {
      db.all(sql, params, (err, rows) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(rows as T[]);
      });
    });

  const close = () =>
    new Promise<void>((resolve, reject) => {
      db.close((err) => {
        if (err) {
          reject(err);
          return;
        }
        resolve();
      });
    });

  return { run, get, all, close };
};

export const resolveDbPath = () => {
  if (process.env.DB_PATH && process.env.DB_PATH.trim() !== '') {
    return process.env.DB_PATH;
  }
  if (process.env.NODE_ENV === 'test') {
    return ':memory:';
  }
  return path.join(process.cwd(), 'data', 'baguzhan.db');
};

export const openDatabase = (dbPath = resolveDbPath()): DbClient => {
  const db = new sqlite3.Database(dbPath);
  db.serialize(() => {
    db.run('PRAGMA foreign_keys = ON');
  });
  return createClient(db);
};
