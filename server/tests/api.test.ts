import request from 'supertest';
import { describe, it, expect, beforeAll, afterAll } from 'vitest';

import { createApp } from '../src/app';
import type { DbClient } from '../src/database/connection';
import { setupTestDb } from './testDb';

describe('Questions API', () => {
  let db: DbClient;
  let app: ReturnType<typeof createApp>;

  beforeAll(async () => {
    db = await setupTestDb();
    app = createApp(db);
  });

  afterAll(async () => {
    await db.close();
  });

  it('health 端点可用', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });

  it('按条件获取题目', async () => {
    const response = await request(app)
      .get('/questions')
      .query({ topic: 'JavaScript', difficulty: 'easy', limit: 2 });

    expect(response.status).toBe(200);
    expect(response.body.length).toBe(2);
    expect(response.body[0].topic).toBe('JavaScript');
  });

  it('随机获取题目', async () => {
    const response = await request(app)
      .get('/questions/random')
      .query({ topic: 'React', count: 1 });

    expect(response.status).toBe(200);
    expect(response.body.length).toBe(1);
  });

  it('按 id 获取题目', async () => {
    const response = await request(app).get('/questions/react-1');
    expect(response.status).toBe(200);
    expect(response.body.id).toBe('react-1');
  });

  it('不存在题目返回 404', async () => {
    const response = await request(app).get('/questions/not-exist');
    expect(response.status).toBe(404);
  });
});
