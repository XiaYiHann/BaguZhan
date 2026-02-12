import { Router } from 'express';

import type { AdminController } from '../controllers/AdminController';
import { asyncHandler } from '../middlewares/asyncHandler';
import { requireApiKey } from '../middleware/apiKeyAuth';

export const createAdminRouter = (controller: AdminController) => {
  const router = Router();

  // 登录端点不需要认证
  router.post('/login', asyncHandler(controller.login));

  // 以下端点需要 API Key 认证
  router.use(requireApiKey);

  // 题目 CRUD
  router.get('/questions', asyncHandler(controller.listQuestions));
  router.get('/questions/:id', asyncHandler(controller.getQuestion));
  router.post('/questions', asyncHandler(controller.createQuestion));
  router.put('/questions/:id', asyncHandler(controller.updateQuestion));
  router.delete('/questions/:id', asyncHandler(controller.deleteQuestion));

  // 批量导入
  router.post('/questions/import', asyncHandler(controller.importQuestions));

  // 统计信息
  router.get('/stats', asyncHandler(controller.getStats));

  return router;
};
