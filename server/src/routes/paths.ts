import { Router } from 'express';
import type { PathService } from '../services/PathService';
import { asyncHandler } from '../middlewares/asyncHandler';

export const createPathRouter = (service: PathService): Router => {
  const router = Router();

  // 获取学习路径
  router.get(
    '/:techStack',
    asyncHandler(async (req, res) => {
      const { techStack } = req.params;
      const { userId } = req.query;

      const result = await service.getLearningPath(
        techStack,
        typeof userId === 'string' ? userId : undefined
      );

      res.json(result);
    })
  );

  // 获取路径分类列表
  router.get(
    '/:techStack/categories',
    asyncHandler(async (req, res) => {
      const { techStack } = req.params;

      const result = await service.getPathCategories(techStack);

      res.json(result);
    })
  );

  // 获取分类下的节点列表
  router.get(
    '/categories/:categoryId/nodes',
    asyncHandler(async (req, res) => {
      const { categoryId } = req.params;
      const { userId } = req.query;

      const result = await service.getCategoryNodes(
        categoryId,
        typeof userId === 'string' ? userId : undefined
      );

      res.json(result);
    })
  );

  // 获取节点的题目
  router.get(
    '/nodes/:nodeId/questions',
    asyncHandler(async (req, res) => {
      const { nodeId } = req.params;

      // 这里直接调用 repository 获取题目
      // 由于 service 中没有对应方法，我们需要从 repository 获取
      // 但为了保持架构一致性，我们在 service 中添加一个简单的方法
      // 或者直接在路由中处理（这里选择直接处理，保持简单）
      const questions = await (service as unknown as { repository: { getNodeQuestions: (id: string) => Promise<unknown[]> } }).repository.getNodeQuestions(nodeId);

      res.json({ nodeId, questions });
    })
  );

  // 完成节点
  router.post(
    '/nodes/:nodeId/complete',
    asyncHandler(async (req, res) => {
      const { nodeId } = req.params;
      const { userId, correctCount, totalCount } = req.body;

      if (!userId || typeof userId !== 'string') {
        res.status(400).json({ error: '用户ID不能为空' });
        return;
      }

      if (typeof correctCount !== 'number' || typeof totalCount !== 'number') {
        res.status(400).json({ error: '答题数量必须是数字' });
        return;
      }

      const result = await service.completeNodeAndUnlockNext(
        userId,
        nodeId,
        correctCount,
        totalCount
      );

      res.json(result);
    })
  );

  return router;
};
