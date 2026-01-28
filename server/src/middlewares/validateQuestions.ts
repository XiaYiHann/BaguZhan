import type { NextFunction, Request, Response } from 'express';

import { HttpError } from '../errors/HttpError';

const ALLOWED_DIFFICULTIES = ['easy', 'medium', 'hard'];

const ensureNumber = (value: string, field: string) => {
  if (!Number.isFinite(Number(value))) {
    throw new HttpError(400, `${field} 必须是数字`);
  }
};

export const validateListQuery = (req: Request, _res: Response, next: NextFunction) => {
  const { difficulty, limit, offset } = req.query;

  if (difficulty && !ALLOWED_DIFFICULTIES.includes(String(difficulty))) {
    throw new HttpError(400, '难度参数不合法');
  }
  if (limit !== undefined) {
    ensureNumber(String(limit), 'limit');
  }
  if (offset !== undefined) {
    ensureNumber(String(offset), 'offset');
  }
  next();
};

export const validateRandomQuery = (req: Request, _res: Response, next: NextFunction) => {
  const { difficulty, count } = req.query;
  if (difficulty && !ALLOWED_DIFFICULTIES.includes(String(difficulty))) {
    throw new HttpError(400, '难度参数不合法');
  }
  if (count !== undefined) {
    ensureNumber(String(count), 'count');
  }
  next();
};
