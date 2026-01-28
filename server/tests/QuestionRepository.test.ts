import { describe, it, expect, beforeAll, afterAll } from 'vitest';

import { QuestionRepository } from '../src/repositories/QuestionRepository';
import type { DbClient } from '../src/database/connection';
import { setupTestDb } from './testDb';

describe('QuestionRepository', () => {
  let db: DbClient;
  let repository: QuestionRepository;

  beforeAll(async () => {
    db = await setupTestDb();
    repository = new QuestionRepository(db);
  });

  afterAll(async () => {
    await db.close();
  });

  it('可以按 topic 筛选题目', async () => {
    const result = await repository.getAll({ topic: 'JavaScript', limit: 10, offset: 0 });
    expect(result.length).toBe(5);
    expect(result[0].options.length).toBe(4);
    expect(result.every((item) => item.topic === 'JavaScript')).toBe(true);
  });

  it('可以按 id 获取题目', async () => {
    const question = await repository.getById('react-1');
    expect(question).not.toBeNull();
    expect(question?.id).toBe('react-1');
    expect(question?.options.length).toBe(4);
  });

  it('可以随机返回指定数量题目', async () => {
    const result = await repository.getRandom({ topic: 'JavaScript', count: 2 });
    expect(result.length).toBe(2);
    expect(result.every((item) => item.topic === 'JavaScript')).toBe(true);
  });
});
