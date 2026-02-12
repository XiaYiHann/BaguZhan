import { describe, it, expect, beforeEach, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { createApp } from '../../app';
import type { DbClient } from '../../database/connection';
import { openDatabase } from '../../database/connection';
import path from 'node:path';
import { executeSqlFile } from '../../database/sql';

describe('UserProgress API', () => {
  let db: DbClient;
  let app: ReturnType<typeof createApp>;
  const testDeviceId = '550e8400-e29b-41d4-a716-446655440001';

  beforeAll(async () => {
    db = openDatabase(':memory:');
    app = createApp(db);

    // Run migrations
    const schemaPath = path.join(__dirname, '../../database/sql/schema.sql');
    await executeSqlFile(db, schemaPath);

    // Insert test question
    await db.run(
      `INSERT INTO questions (id, content, topic, difficulty) VALUES (?, ?, ?, ?)`,
      ['test-q-1', 'Test question', 'JavaScript', 'easy']
    );
    await db.run(
      `INSERT INTO options (id, question_id, option_text, option_order, is_correct) VALUES (?, ?, ?, ?, ?)`,
      ['test-opt-1', 'test-q-1', 'Option A', 0, 1]
    );
  });

  afterAll(async () => {
    await db.close();
  });

  beforeEach(async () => {
    // Clean up user progress tables
    await db.run('DELETE FROM user_answers');
    await db.run('DELETE FROM wrong_book');
    await db.run('DELETE FROM learning_progress');
  });

  // Helper to make requests with device ID header
  const withDeviceId = (method: string, path: string) => {
    return request(app)[method](path).set('X-Device-ID', testDeviceId);
  };

  describe('POST /api/answers', () => {
    it('should record a correct answer', async () => {
      const response = await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: true,
        answerTimeMs: 5000,
      });

      expect(response.status).toBe(201);
      expect(response.body).toMatchObject({
        questionId: 'test-q-1',
        isCorrect: true,
        answerTimeMs: 5000,
      });
    });

    it('should record wrong answer and add to wrong book', async () => {
      const response = await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: false,
      });

      expect(response.status).toBe(201);
      expect(response.body.isCorrect).toBe(false);

      // Check wrong book
      const wrongBookRes = await withDeviceId('get', '/api/wrong-book');

      expect(wrongBookRes.body).toHaveLength(1);
      expect(wrongBookRes.body[0].questionId).toBe('test-q-1');
    });

    it('should return 400 for missing fields', async () => {
      const response = await withDeviceId('post', '/api/answers').send({
      });

      expect(response.status).toBe(400);
    });
  });

  describe('GET /api/answers', () => {
    it('should get answer history', async () => {
      // Create some answers
      await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: true,
      });

      const response = await withDeviceId('get', '/api/answers');

      expect(response.status).toBe(200);
      expect(response.body.answers).toHaveLength(1);
      expect(response.body.total).toBe(1);
    });
  });

  describe('GET /api/wrong-book', () => {
    it('should get wrong book items', async () => {
      // Add to wrong book
      await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: false,
      });

      const response = await withDeviceId('get', '/api/wrong-book');

      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(1);
      expect(response.body[0].isMastered).toBe(false);
    });

    it('should filter by isMastered', async () => {
      // Add to wrong book and mark as mastered
      await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: false,
      });

      const wrongBookRes = await withDeviceId('get', '/api/wrong-book');
      const wrongBookId = wrongBookRes.body[0].id;

      await withDeviceId('patch', `/api/wrong-book/${wrongBookId}/master`);

      const response = await withDeviceId('get', '/api/wrong-book')
        .query({ isMastered: 'false' });

      expect(response.body).toHaveLength(0);
    });
  });

  describe('PATCH /api/wrong-book/:id/master', () => {
    it('should mark wrong book as mastered', async () => {
      // Add to wrong book
      await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: false,
      });

      const wrongBookRes = await withDeviceId('get', '/api/wrong-book');
      const wrongBookId = wrongBookRes.body[0].id;

      const response = await withDeviceId('patch', `/api/wrong-book/${wrongBookId}/master`);

      expect(response.status).toBe(200);
      expect(response.body.isMastered).toBe(true);
      expect(response.body.masteredAt).toBeDefined();
    });

    it('should return 404 for non-existent id', async () => {
      const response = await withDeviceId('patch', '/api/wrong-book/non-existent-id/master');
      expect(response.status).toBe(404);
    });
  });

  describe('DELETE /api/wrong-book/:id', () => {
    it('should delete wrong book item', async () => {
      // Add to wrong book
      await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: false,
      });

      const wrongBookRes = await withDeviceId('get', '/api/wrong-book');
      const wrongBookId = wrongBookRes.body[0].id;

      const response = await withDeviceId('delete', `/api/wrong-book/${wrongBookId}`);

      expect(response.status).toBe(204);
    });
  });

  describe('GET /api/progress', () => {
    it('should get learning progress', async () => {
      // Record some answers
      await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: true,
      });

      const response = await withDeviceId('get', '/api/progress');

      expect(response.status).toBe(200);
      expect(response.body).toMatchObject({
        totalAnswered: 1,
        totalCorrect: 1,
        accuracyRate: 1,
      });
    });
  });

  describe('GET /api/progress/stats', () => {
    it('should get detailed stats', async () => {
      await withDeviceId('post', '/api/answers').send({
        questionId: 'test-q-1',
        selectedOptionId: 'test-opt-1',
        isCorrect: false,
      });

      const response = await withDeviceId('get', '/api/progress/stats');

      expect(response.status).toBe(200);
      expect(response.body.progress).toBeDefined();
      expect(response.body.wrongBookStats).toBeDefined();
      expect(response.body.wrongBookStats.total).toBe(1);
    });
  });
});
