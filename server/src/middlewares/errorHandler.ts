import type { NextFunction, Request, Response } from 'express';

import { HttpError } from '../errors/HttpError';

export const errorHandler = (
  error: Error,
  _req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction,
) => {
  if (error instanceof HttpError) {
    res.status(error.status).json({
      error: '请求错误',
      message: error.message,
      details: error.details,
    });
    return;
  }

  res.status(500).json({
    error: '服务器错误',
    message: '系统处理失败，请稍后再试',
  });
};
