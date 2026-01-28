import request from 'supertest';
import { describe, it, expect, beforeAll, afterAll } from 'vitest';

import { createApp } from '../../app';
import { openDatabase } from '../../database/connection';

let db: ReturnType<typeof openDatabase>;
let app: ReturnType<typeof createApp>;

beforeAll(() => {
  db = openDatabase(':memory:');
  app = createApp(db);
});

afterAll(async () => {
  await db.close();
});

describe('GET /health', () => {
  it('返回 ok 状态', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      status: 'ok',
    });
  });
});

describe('404 处理器', () => {
  it('未定义路由返回 404', async () => {
    const response = await request(app).get('/nonexistent');

    expect(response.status).toBe(404);
    expect(response.body).toMatchObject({
      error: '资源不存在',
    });
  });
});
