import { Router } from 'express';
import type { UserProgressService } from '../services/UserProgressService';
import { asyncHandler } from '../middlewares/asyncHandler';
import { validateDeviceId } from '../middleware/deviceId';

export const createUserProgressRouter = (
  service: UserProgressService
): Router => {
  const router = Router();

  // 对所有用户进度相关路由应用设备 ID 验证
  router.use(validateDeviceId);

  // Record an answer
  router.post(
    '/answers',
    asyncHandler(async (req, res) => {
      const { questionId, selectedOptionId, isCorrect, answerTimeMs } = req.body;

      if (!questionId || !selectedOptionId || typeof isCorrect !== 'boolean') {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      const answer = await service.recordAnswer({
        userId: req.deviceId!,
        questionId,
        selectedOptionId,
        isCorrect,
        answerTimeMs,
      });

      res.status(201).json(answer);
    })
  );

  // Get answer history
  router.get(
    '/answers',
    asyncHandler(async (req, res) => {
      const { limit = '20', offset = '0' } = req.query;

      const result = await service.getAnswerHistory({
        userId: req.deviceId!,
        limit: parseInt(limit as string, 10),
        offset: parseInt(offset as string, 10),
      });

      res.json(result);
    })
  );

  // Get wrong book
  router.get(
    '/wrong-book',
    asyncHandler(async (req, res) => {
      const { isMastered } = req.query;

      const wrongBooks = await service.getWrongBooks({
        userId: req.deviceId!,
        isMastered:
          isMastered === 'true' ? true : isMastered === 'false' ? false : undefined,
      });

      res.json(wrongBooks);
    })
  );

  // Mark wrong book as mastered
  router.patch(
    '/wrong-book/:id/master',
    asyncHandler(async (req, res) => {
      const { id } = req.params;
      const updated = await service.markWrongBookAsMastered(id);

      if (!updated) {
        res.status(404).json({ error: 'Wrong book item not found' });
        return;
      }

      res.json(updated);
    })
  );

  // Delete wrong book item
  router.delete(
    '/wrong-book/:id',
    asyncHandler(async (req, res) => {
      const { id } = req.params;
      await service.deleteWrongBook(id);
      res.status(204).send();
    })
  );

  // Get learning progress
  router.get(
    '/progress',
    asyncHandler(async (req, res) => {
      const progress = await service.getProgress(req.deviceId!);
      res.json(progress);
    })
  );

  // Get detailed stats
  router.get(
    '/progress/stats',
    asyncHandler(async (req, res) => {
      const stats = await service.getDetailedStats(req.deviceId!);
      res.json(stats);
    })
  );

  return router;
};
