import type { Request, Response } from 'express';

export class HealthController {
  getStatus = (_req: Request, res: Response) => {
    res.json({ status: 'ok' });
  };
}
