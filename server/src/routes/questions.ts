import { Router } from 'express';

import type { QuestionController } from '../controllers/QuestionController';
import { asyncHandler } from '../middlewares/asyncHandler';
import { validateListQuery, validateRandomQuery } from '../middlewares/validateQuestions';

export const createQuestionRouter = (controller: QuestionController) => {
  const router = Router();

  router.get('/', validateListQuery, asyncHandler(controller.list));
  router.get('/random', validateRandomQuery, asyncHandler(controller.random));
  router.get('/:id', asyncHandler(controller.getById));

  return router;
};
