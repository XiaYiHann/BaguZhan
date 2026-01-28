import { describe, it, expect, beforeAll, afterAll } from 'vitest';

import { QuestionService } from '../src/services/QuestionService';
import { QuestionRepository } from '../src/repositories/QuestionRepository';
import { HttpError } from '../src/errors/HttpError';
import type { DbClient } from '../src/database/connection';
import { setupTestDb } from './testDb';

describe('QuestionService', () => {
  let db: DbClient;
  let service: QuestionService;

  beforeAll(async () => {
    db = await setupTestDb();
    const repository = new QuestionRepository(db);
    service = new QuestionService(repository);
  });

  afterAll(async () => {
    await db.close();
  });

  it('默认返回题目列表', async () => {
    const result = await service.queryQuestions({ topic: 'React' });
    expect(result.length).toBe(2);
  });

  it('无效难度会抛出错误', async () => {
    let error: unknown;
    try {
      await service.queryQuestions({ difficulty: 'invalid' });
    } catch (err) {
      error = err;
    }
    expect(error).toBeInstanceOf(HttpError);
    expect((error as HttpError).status).toBe(400);
  });
});
