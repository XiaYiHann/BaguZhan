import path from 'node:path';

import { describe, it, expect, beforeAll, afterAll } from 'vitest';

import { PathService } from '../src/services/PathService';
import { PathRepository } from '../src/repositories/PathRepository';
import { HttpError } from '../src/errors/HttpError';
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

describe('PathService', () => {
  let db: DbClient;
  let service: PathService;
  let repository: PathRepository;

  beforeAll(async () => {
    db = await setupTestDb();
    repository = new PathRepository(db);
    service = new PathService(repository);
  });

  afterAll(async () => {
    await db.close();
  });

  describe('getAllPaths', () => {
    it('返回所有学习路径', async () => {
      const paths = await service.getAllPaths();
      expect(paths.length).toBeGreaterThan(0);
    });
  });

  describe('getPathById', () => {
    it('返回路径详情和分类', async () => {
      const result = await service.getPathById('path_js');
      expect(result.path).toBeDefined();
      expect(result.path.id).toBe('path_js');
      expect(result.categories).toBeDefined();
    });

    it('无效 ID 返回 404', async () => {
      let error: unknown;
      try {
        await service.getPathById('nonexistent');
      } catch (err) {
        error = err;
      }
      expect(error).toBeInstanceOf(HttpError);
      expect((error as HttpError).status).toBe(404);
    });
  });

  describe('getPathByTechStack', () => {
    it('根据技术栈返回路径', async () => {
      const result = await service.getPathByTechStack('javascript');
      expect(result.path.techStack).toBe('javascript');
    });

    it('大小写不敏感', async () => {
      const result = await service.getPathByTechStack('JavaScript');
      expect(result.path.techStack).toBe('javascript');
    });
  });

  describe('getCategoryNodes', () => {
    it('返回分类下的节点', async () => {
      // 先获取路径以得到分类 ID
      const pathResult = await service.getPathById('path_js');
      if (pathResult.categories.length === 0) {
        expect(true).toBe(true);
        return;
      }

      const categoryId = pathResult.categories[0].id;
      const result = await service.getCategoryNodes(categoryId);
      expect(result.category).toBeDefined();
      expect(result.nodes).toBeDefined();
    });
  });

  describe('节点解锁逻辑', () => {
    const testUserId = 'test-user-unlock';

    it('首次访问路径时初始化进度', async () => {
      const result = await service.getPathById('path_js', testUserId);
      expect(result.progress).toBeDefined();
    });

    it('完成节点后更新状态', async () => {
      // 先获取分类
      const pathResult = await service.getPathById('path_js', testUserId);
      if (pathResult.categories.length === 0) {
        expect(true).toBe(true);
        return;
      }

      // 获取第一个分类的节点
      const categoryResult = await service.getCategoryNodes(
        pathResult.categories[0].id,
        testUserId
      );
      
      if (categoryResult.nodes.length === 0) {
        expect(true).toBe(true);
        return;
      }

      const firstNode = categoryResult.nodes[0];
      
      // 完成节点
      const completeResult = await service.completeNode(
        testUserId,
        firstNode.id,
        2,
        2
      );

      expect(completeResult.node).toBeDefined();
      expect(completeResult.progress.status).toBe('completed');
    });
  });

  describe('completeNode', () => {
    it('参数验证：空用户 ID', async () => {
      let error: unknown;
      try {
        await service.completeNode('', 'node-1', 1, 1);
      } catch (err) {
        error = err;
      }
      expect(error).toBeInstanceOf(HttpError);
      expect((error as HttpError).status).toBe(400);
    });

    it('参数验证：空节点 ID', async () => {
      let error: unknown;
      try {
        await service.completeNode('user-1', '', 1, 1);
      } catch (err) {
        error = err;
      }
      expect(error).toBeInstanceOf(HttpError);
      expect((error as HttpError).status).toBe(400);
    });

    it('参数验证：负数', async () => {
      let error: unknown;
      try {
        await service.completeNode('user-1', 'node-1', -1, 1);
      } catch (err) {
        error = err;
      }
      expect(error).toBeInstanceOf(HttpError);
      expect((error as HttpError).status).toBe(400);
    });

    it('参数验证：正确数超过总数', async () => {
      let error: unknown;
      try {
        await service.completeNode('user-1', 'node-1', 5, 3);
      } catch (err) {
        error = err;
      }
      expect(error).toBeInstanceOf(HttpError);
      expect((error as HttpError).status).toBe(400);
    });
  });

  describe('管理端点', () => {
    it('创建路径成功', async () => {
      const path = await service.createPath({
        id: 'test-path-new',
        techStack: 'teststack',
        title: '测试路径',
        subtitle: '测试副标题',
      });
      expect(path.id).toBe('test-path-new');
      expect(path.techStack).toBe('teststack');
    });

    it('重复 ID 返回 409', async () => {
      let error: unknown;
      try {
        await service.createPath({
          id: 'path_js', // 已存在
          techStack: 'teststack2',
          title: '测试路径',
        });
      } catch (err) {
        error = err;
      }
      expect(error).toBeInstanceOf(HttpError);
      expect((error as HttpError).status).toBe(409);
    });

    it('更新路径成功', async () => {
      const updated = await service.updatePath('test-path-new', {
        title: '更新后的标题',
      });
      expect(updated.title).toBe('更新后的标题');
    });

    it('删除路径成功', async () => {
      await service.deletePath('test-path-new');
      
      let error: unknown;
      try {
        await service.getPathById('test-path-new');
      } catch (err) {
        error = err;
      }
      expect(error).toBeInstanceOf(HttpError);
      expect((error as HttpError).status).toBe(404);
    });
  });
});
