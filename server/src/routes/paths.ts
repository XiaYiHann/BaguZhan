import { Router } from 'express';
import type { PathService } from '../services/PathService';
import { asyncHandler } from '../middlewares/asyncHandler';
import { requireApiKey } from '../middleware/apiKeyAuth';
import type { CreatePathInput, UpdatePathInput, CreateCategoryInput, UpdateCategoryInput, CreateNodeInput, UpdateNodeInput } from '../repositories/PathRepository';

export const createPathRouter = (service: PathService): Router => {
  const router = Router();

  // ============ Public Endpoints ============

  /**
   * GET /api/paths
   * 获取所有学习路径
   */
  router.get(
    '/',
    asyncHandler(async (req, res) => {
      const paths = await service.getAllPaths();
      res.json(paths);
    })
  );

  /**
   * GET /api/paths/:id
   * 获取学习路径详情
   */
  router.get(
    '/:id',
    asyncHandler(async (req, res) => {
      const userId = req.headers['x-device-id'] as string | undefined;
      const result = await service.getPathById(req.params.id, userId);
      res.json(result);
    })
  );

  /**
   * GET /api/paths/tech/:techStack
   * 根据技术栈获取学习路径
   */
  router.get(
    '/tech/:techStack',
    asyncHandler(async (req, res) => {
      const userId = req.headers['x-device-id'] as string | undefined;
      const result = await service.getPathByTechStack(req.params.techStack, userId);
      res.json(result);
    })
  );

  /**
   * GET /api/paths/:id/progress
   * 获取用户在路径上的进度
   */
  router.get(
    '/:id/progress',
    asyncHandler(async (req, res) => {
      const userId = req.headers['x-device-id'] as string;
      if (!userId) {
        res.status(400).json({ error: '缺少设备 ID' });
        return;
      }
      const result = await service.getUserProgress(userId, req.params.id);
      res.json(result);
    })
  );

  /**
   * GET /api/paths/categories/:categoryId/nodes
   * 获取分类下的节点
   */
  router.get(
    '/categories/:categoryId/nodes',
    asyncHandler(async (req, res) => {
      const userId = req.headers['x-device-id'] as string | undefined;
      const result = await service.getCategoryNodes(req.params.categoryId, userId);
      res.json(result);
    })
  );

  /**
   * POST /api/paths/nodes/:nodeId/complete
   * 完成节点
   */
  router.post(
    '/nodes/:nodeId/complete',
    asyncHandler(async (req, res) => {
      const userId = req.headers['x-device-id'] as string;
      if (!userId) {
        res.status(400).json({ error: '缺少设备 ID' });
        return;
      }

      const { correctCount, totalCount } = req.body;
      if (typeof correctCount !== 'number' || typeof totalCount !== 'number') {
        res.status(400).json({ error: '答题数量必须是数字' });
        return;
      }

      const result = await service.completeNode(userId, req.params.nodeId, correctCount, totalCount);
      res.json(result);
    })
  );

  // ============ Admin Endpoints ============

  // 所有管理端点需要 API Key 认证
  router.use(requireApiKey);

  /**
   * POST /api/paths/admin/paths
   * 创建学习路径
   */
  router.post(
    '/admin/paths',
    asyncHandler(async (req, res) => {
      const input: CreatePathInput = req.body;
      const path = await service.createPath(input);
      res.status(201).json(path);
    })
  );

  /**
   * PUT /api/paths/admin/paths/:id
   * 更新学习路径
   */
  router.put(
    '/admin/paths/:id',
    asyncHandler(async (req, res) => {
      const input: UpdatePathInput = req.body;
      const path = await service.updatePath(req.params.id, input);
      res.json(path);
    })
  );

  /**
   * DELETE /api/paths/admin/paths/:id
   * 删除学习路径
   */
  router.delete(
    '/admin/paths/:id',
    asyncHandler(async (req, res) => {
      await service.deletePath(req.params.id);
      res.status(204).send();
    })
  );

  /**
   * POST /api/paths/admin/categories
   * 创建分类
   */
  router.post(
    '/admin/categories',
    asyncHandler(async (req, res) => {
      const input: CreateCategoryInput = req.body;
      const category = await service.createCategory(input);
      res.status(201).json(category);
    })
  );

  /**
   * PUT /api/paths/admin/categories/:id
   * 更新分类
   */
  router.put(
    '/admin/categories/:id',
    asyncHandler(async (req, res) => {
      const input: UpdateCategoryInput = req.body;
      const category = await service.updateCategory(req.params.id, input);
      res.json(category);
    })
  );

  /**
   * DELETE /api/paths/admin/categories/:id
   * 删除分类
   */
  router.delete(
    '/admin/categories/:id',
    asyncHandler(async (req, res) => {
      await service.deleteCategory(req.params.id);
      res.status(204).send();
    })
  );

  /**
   * POST /api/paths/admin/nodes
   * 创建节点
   */
  router.post(
    '/admin/nodes',
    asyncHandler(async (req, res) => {
      const input: CreateNodeInput = req.body;
      const node = await service.createNode(input);
      res.status(201).json(node);
    })
  );

  /**
   * PUT /api/paths/admin/nodes/:id
   * 更新节点
   */
  router.put(
    '/admin/nodes/:id',
    asyncHandler(async (req, res) => {
      const input: UpdateNodeInput = req.body;
      const node = await service.updateNode(req.params.id, input);
      res.json(node);
    })
  );

  /**
   * DELETE /api/paths/admin/nodes/:id
   * 删除节点
   */
  router.delete(
    '/admin/nodes/:id',
    asyncHandler(async (req, res) => {
      await service.deleteNode(req.params.id);
      res.status(204).send();
    })
  );

  return router;
};
