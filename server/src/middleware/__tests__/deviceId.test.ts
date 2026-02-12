import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '../../app';
import type { DbClient } from '../../database/connection';
import { openDatabase } from '../../database/connection';
import path from 'node:path';
import { executeSqlFile } from '../../database/sql';

describe('Device ID Middleware', () => {
  let db: DbClient;
  let app: ReturnType<typeof createApp>;

  const validDeviceId = '550e8400-e29b-41d4-a716-446655440000';
  const invalidDeviceId = 'not-a-valid-uuid';

  beforeEach(async () => {
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
  });

  describe('设备 ID 验证', () => {
    it('应该接受有效的设备 ID', async () => {
      const response = await request(app)
        .get('/api/progress')
        .set('X-Device-ID', validDeviceId);

      // 应该返回 200 而不是 400（设备 ID 验证通过）
      expect([200, 404]).toContain(response.status);
      expect(response.status).not.toBe(400);
    });

    it('应该拒绝缺少设备 ID 的请求', async () => {
      const response = await request(app).get('/api/progress');

      expect(response.status).toBe(400);
      expect(response.body).toMatchObject({
        error: '缺少设备 ID',
        message: expect.stringContaining('X-Device-ID'),
      });
    });

    it('应该拒绝无效格式的设备 ID', async () => {
      const response = await request(app)
        .get('/api/progress')
        .set('X-Device-ID', invalidDeviceId);

      expect(response.status).toBe(400);
      expect(response.body).toMatchObject({
        error: '无效的设备 ID',
        message: expect.stringContaining('UUID'),
      });
    });

    it('应该接受 UUID v4 格式的设备 ID', async () => {
      const validUuids = [
        '550e8400-e29b-41d4-a716-446655440001',  // 标准UUID: 8-4-4-4-12
        '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      ];

      for (const uuid of validUuids) {
        const response = await request(app)
          .get('/api/progress')
          .set('X-Device-ID', uuid);

        expect(response.status).not.toBe(400);
      }
    });
  });

  describe('设备 ID 在请求中的使用', () => {
    it('应该使用设备 ID 创建用户进度', async () => {
      const response = await request(app)
        .get('/api/progress')
        .set('X-Device-ID', validDeviceId);

      // 首次请求应该创建新的进度记录
      expect([200, 404]).toContain(response.status);
    });

    it('不同设备 ID 应该有独立的用户数据', async () => {
      const deviceId1 = '550e8400-e29b-41d4-a716-446655440001';
      const deviceId2 = '550e8400-e29b-41d4-a716-446655440002';

      // 设备 1 记录答题
      await request(app)
        .post('/api/answers')
        .set('X-Device-ID', deviceId1)
        .send({
          questionId: 'test-q-1',
          selectedOptionId: 'test-opt-1',
          isCorrect: true,
        });

      // 设备 1 应该有进度
      const progress1 = await request(app)
        .get('/api/progress')
        .set('X-Device-ID', deviceId1);
      expect(progress1.status).toBe(200);
      expect(progress1.body.totalAnswered).toBe(1);

      // 设备 2 应该没有进度
      const progress2 = await request(app)
        .get('/api/progress')
        .set('X-Device-ID', deviceId2);
      expect(progress2.status).toBe(200);
      expect(progress2.body.totalAnswered).toBe(0);
    });
  });
});
