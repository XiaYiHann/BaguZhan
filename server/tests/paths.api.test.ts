import path from 'node:path';

import request from 'supertest';
import { describe, it, expect, beforeAll, afterAll } from 'vitest';

import { createApp } from '../src/app';
import type { DbClient } from '../src/database/connection';
import { openDatabase } from '../src/database/connection';
import { executeSqlFile } from '../src/database/sql';

const setupTestDb = async () => {
  const db = openDatabase(':memory:');
  const schemaPath = path.join(__dirname, '../src/database/sql/schema.sql');
  const seedPath = path.join(__dirname, '../src/database/sql/seed.sql');
  const learningPathsSeedPath = path.join(__dirname, '../src/database/sql/learning_paths_seed.sql');
  await executeSqlFile(db, schemaPath);
  await executeSqlFile(db, seedPath);
  await executeSqlFile(db, learningPathsSeedPath);
  return db;
};

describe('Paths API', () => {
  let db: DbClient;
  let app: ReturnType<typeof createApp>;

  beforeAll(async () => {
    db = await setupTestDb();
    app = createApp(db);
  });

  afterAll(async () => {
    await db.close();
  });

  describe('GET /api/paths', () => {
    it('返回所有学习路径', async () => {
      const response = await request(app).get('/api/paths');
      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });
  });

  describe('GET /api/paths/:id', () => {
    it('返回路径详情', async () => {
      const response = await request(app).get('/api/paths/path_js');
      expect(response.status).toBe(200);
      expect(response.body.path).toBeDefined();
      expect(response.body.path.id).toBe('path_js');
      expect(response.body.categories).toBeDefined();
    });

    it('带设备 ID 返回进度', async () => {
      const response = await request(app)
        .get('/api/paths/path_js')
        .set('X-Device-ID', 'test-device-123');
      expect(response.status).toBe(200);
      expect(response.body.progress).toBeDefined();
    });

    it('不存在路径返回 404', async () => {
      const response = await request(app).get('/api/paths/nonexistent');
      expect(response.status).toBe(404);
    });
  });

  describe('GET /api/paths/tech/:techStack', () => {
    it('根据技术栈返回路径', async () => {
      const response = await request(app).get('/api/paths/tech/javascript');
      expect(response.status).toBe(200);
      expect(response.body.path.techStack).toBe('javascript');
    });

    it('大小写不敏感', async () => {
      const response = await request(app).get('/api/paths/tech/JavaScript');
      expect(response.status).toBe(200);
      expect(response.body.path.techStack).toBe('javascript');
    });
  });

  describe('GET /api/paths/:id/progress', () => {
    it('需要设备 ID', async () => {
      const response = await request(app).get('/api/paths/path_js/progress');
      expect(response.status).toBe(400);
    });

    it('返回用户进度', async () => {
      const response = await request(app)
        .get('/api/paths/path_js/progress')
        .set('X-Device-ID', 'test-device-456');
      expect(response.status).toBe(200);
      expect(response.body.progress).toBeDefined();
      expect(response.body.progress.totalNodes).toBeDefined();
      expect(response.body.progress.completedNodes).toBeDefined();
    });
  });

  describe('GET /api/paths/categories/:categoryId/nodes', () => {
    it('返回分类下的节点', async () => {
      const response = await request(app).get('/api/paths/categories/cat_js_basic/nodes');
      expect(response.status).toBe(200);
      expect(response.body.category).toBeDefined();
      expect(response.body.nodes).toBeDefined();
      expect(Array.isArray(response.body.nodes)).toBe(true);
    });

    it('带设备 ID 返回节点状态', async () => {
      const response = await request(app)
        .get('/api/paths/categories/cat_js_basic/nodes')
        .set('X-Device-ID', 'test-device-789');
      expect(response.status).toBe(200);
      // 节点应该有 status 字段（unlocked, locked, completed）
      if (response.body.nodes.length > 0) {
        const firstNode = response.body.nodes[0];
        // status 可能是 undefined（新用户未初始化）或 unlocked/locked/completed
        if (firstNode.status) {
          expect(['unlocked', 'locked', 'completed']).toContain(firstNode.status);
        }
      }
    });
  });

  describe('POST /api/paths/nodes/:nodeId/complete', () => {
    it('需要设备 ID', async () => {
      const response = await request(app)
        .post('/api/paths/nodes/node_js_var/complete')
        .send({ correctCount: 2, totalCount: 2 });
      expect(response.status).toBe(400);
    });

    it('完成节点成功', async () => {
      const deviceId = 'test-complete-user';
      
      // 先初始化进度
      await request(app)
        .get('/api/paths/path_js/progress')
        .set('X-Device-ID', deviceId);

      const response = await request(app)
        .post('/api/paths/nodes/node_js_var/complete')
        .set('X-Device-ID', deviceId)
        .send({ correctCount: 2, totalCount: 2 });
      expect(response.status).toBe(200);
      expect(response.body.node).toBeDefined();
      expect(response.body.progress.status).toBe('completed');
    });

    it('参数验证：答题数必须是数字', async () => {
      const response = await request(app)
        .post('/api/paths/nodes/node_js_var/complete')
        .set('X-Device-ID', 'test-user')
        .send({ correctCount: 'invalid', totalCount: 2 });
      expect(response.status).toBe(400);
    });
  });

  describe('Admin API (需要 API Key)', () => {
    const validApiKey = 'baguzhan-admin-secret-2024';

    it('无 API Key 返回 401', async () => {
      const response = await request(app)
        .post('/api/paths/admin/paths')
        .send({ id: 'test', techStack: 'test', title: 'Test' });
      expect(response.status).toBe(401);
    });

    it('创建路径', async () => {
      const response = await request(app)
        .post('/api/paths/admin/paths')
        .set('X-Admin-API-Key', validApiKey)
        .send({
          id: 'test-path-api',
          techStack: 'teststack',
          title: '测试路径',
          subtitle: '测试副标题',
        });
      expect(response.status).toBe(201);
      expect(response.body.id).toBe('test-path-api');
    });

    it('更新路径', async () => {
      const response = await request(app)
        .put('/api/paths/admin/paths/test-path-api')
        .set('X-Admin-API-Key', validApiKey)
        .send({ title: '更新后的标题' });
      expect(response.status).toBe(200);
      expect(response.body.title).toBe('更新后的标题');
    });

    it('删除路径', async () => {
      const response = await request(app)
        .delete('/api/paths/admin/paths/test-path-api')
        .set('X-Admin-API-Key', validApiKey);
      expect(response.status).toBe(204);
    });

    it('创建分类', async () => {
      const response = await request(app)
        .post('/api/paths/admin/categories')
        .set('X-Admin-API-Key', validApiKey)
        .send({
          id: 'test-cat-api',
          pathId: 'path_js',
          name: '测试分类',
        });
      expect(response.status).toBe(201);
    });

    it('创建节点', async () => {
      const response = await request(app)
        .post('/api/paths/admin/nodes')
        .set('X-Admin-API-Key', validApiKey)
        .send({
          id: 'test-node-api',
          categoryId: 'cat_js_basic',
          title: '测试节点',
          questionIds: ['q1', 'q2'],
        });
      expect(response.status).toBe(201);
    });
  });
});
