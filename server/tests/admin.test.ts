import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';
import type { DbClient } from '../src/database/connection';
import { setupTestDb } from './testDb';
import { config } from '../src/config/config';

describe('Admin API', () => {
  let db: DbClient;
  let app: ReturnType<typeof createApp>;
  const validApiKey = config.adminApiKey;
  const invalidApiKey = 'invalid-key';

  beforeAll(async () => {
    db = await setupTestDb();
    app = createApp(db);
  });

  afterAll(async () => {
    await db.close();
  });

  describe('POST /api/admin/login', () => {
    it('should return token with valid API key', async () => {
      const res = await request(app)
        .post('/api/admin/login')
        .send({ apiKey: validApiKey });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('token');
      expect(res.body).toHaveProperty('expiresIn', 86400);
    });

    it('should reject invalid API key', async () => {
      const res = await request(app)
        .post('/api/admin/login')
        .send({ apiKey: invalidApiKey });

      expect(res.status).toBe(401);
      expect(res.body).toHaveProperty('error');
    });

    it('should reject missing API key', async () => {
      const res = await request(app)
        .post('/api/admin/login')
        .send({});

      expect(res.status).toBe(400);
      expect(res.body).toHaveProperty('error');
    });
  });

  describe('GET /api/admin/questions', () => {
    it('should require API key', async () => {
      const res = await request(app).get('/api/admin/questions');
      expect(res.status).toBe(401);
    });

    it('should return questions with valid API key', async () => {
      const res = await request(app)
        .get('/api/admin/questions')
        .set('X-Admin-API-Key', validApiKey);

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('data');
      expect(res.body).toHaveProperty('pagination');
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it('should filter by topic', async () => {
      const res = await request(app)
        .get('/api/admin/questions?topic=JavaScript')
        .set('X-Admin-API-Key', validApiKey);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });
  });

  describe('POST /api/admin/questions', () => {
    it('should create a new question', async () => {
      const newQuestion = {
        id: 'new-q1',
        content: '新题目',
        topic: 'React',
        difficulty: 'medium',
        options: [
          { optionText: '选项A', optionOrder: 0, isCorrect: true },
          { optionText: '选项B', optionOrder: 1, isCorrect: false },
        ],
      };

      const res = await request(app)
        .post('/api/admin/questions')
        .set('X-Admin-API-Key', validApiKey)
        .send(newQuestion);

      expect(res.status).toBe(201);
      expect(res.body.id).toBe('new-q1');
      expect(res.body.content).toBe('新题目');
    });

    it('should reject invalid question data', async () => {
      const invalidQuestion = {
        id: 'invalid-q',
        content: '', // 空内容
        topic: 'React',
        difficulty: 'medium',
        options: [],
      };

      const res = await request(app)
        .post('/api/admin/questions')
        .set('X-Admin-API-Key', validApiKey)
        .send(invalidQuestion);

      expect(res.status).toBe(422);
    });
  });

  describe('PUT /api/admin/questions/:id', () => {
    it('should update an existing question', async () => {
      const res = await request(app)
        .put('/api/admin/questions/js-1')
        .set('X-Admin-API-Key', validApiKey)
        .send({ content: '更新后的题目' });

      expect(res.status).toBe(200);
      expect(res.body.content).toBe('更新后的题目');
    });

    it('should return 404 for non-existent question', async () => {
      const res = await request(app)
        .put('/api/admin/questions/non-existent')
        .set('X-Admin-API-Key', validApiKey)
        .send({ content: '更新' });

      expect(res.status).toBe(404);
    });
  });

  describe('DELETE /api/admin/questions/:id', () => {
    it('should soft delete a question', async () => {
      const res = await request(app)
        .delete('/api/admin/questions/js-1')
        .set('X-Admin-API-Key', validApiKey);

      expect(res.status).toBe(204);

      // 验证题目被软删除
      const deleted = await db.get<{ deleted_at: string }>(
        'SELECT deleted_at FROM questions WHERE id = ?',
        ['js-1']
      );
      expect(deleted?.deleted_at).not.toBeNull();
    });

    it('should return 404 for non-existent question', async () => {
      const res = await request(app)
        .delete('/api/admin/questions/non-existent')
        .set('X-Admin-API-Key', validApiKey);

      expect(res.status).toBe(404);
    });
  });

  describe('POST /api/admin/questions/import', () => {
    it('should import multiple questions', async () => {
      const questions = [
        {
          id: 'import-q1',
          content: '导入题目1',
          topic: 'Vue',
          difficulty: 'easy',
          options: [
            { optionText: 'A', optionOrder: 0, isCorrect: true },
            { optionText: 'B', optionOrder: 1, isCorrect: false },
          ],
        },
        {
          id: 'import-q2',
          content: '导入题目2',
          topic: 'Vue',
          difficulty: 'medium',
          options: [
            { optionText: 'A', optionOrder: 0, isCorrect: true },
            { optionText: 'B', optionOrder: 1, isCorrect: false },
          ],
        },
      ];

      const res = await request(app)
        .post('/api/admin/questions/import')
        .set('X-Admin-API-Key', validApiKey)
        .send(questions);

      expect(res.status).toBe(200);
      expect(res.body.imported).toBe(2);
      expect(res.body.failed).toBe(0);
    });

    it('should report errors for invalid questions', async () => {
      const questions = [
        {
          id: 'valid-q',
          content: '有效题目',
          topic: 'Vue',
          difficulty: 'easy',
          options: [
            { optionText: 'A', optionOrder: 0, isCorrect: true },
            { optionText: 'B', optionOrder: 1, isCorrect: false },
          ],
        },
        {
          id: 'invalid-q',
          content: '', // 无效：空内容
          topic: 'Vue',
          difficulty: 'easy',
          options: [],
        },
      ];

      const res = await request(app)
        .post('/api/admin/questions/import')
        .set('X-Admin-API-Key', validApiKey)
        .send(questions);

      expect(res.status).toBe(200);
      expect(res.body.imported).toBe(1);
      expect(res.body.failed).toBe(1);
      expect(res.body.errors.length).toBe(1);
    });
  });

  describe('GET /api/admin/stats', () => {
    it('should return question statistics', async () => {
      const res = await request(app)
        .get('/api/admin/stats')
        .set('X-Admin-API-Key', validApiKey);

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('total');
      expect(res.body).toHaveProperty('byTopic');
      expect(res.body).toHaveProperty('byDifficulty');
    });
  });
});
