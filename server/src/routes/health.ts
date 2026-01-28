import { Router } from 'express';

import type { HealthController } from '../controllers/HealthController';

export const createHealthRouter = (controller: HealthController) => {
  const router = Router();

  router.get('/', controller.getStatus);

  return router;
};
