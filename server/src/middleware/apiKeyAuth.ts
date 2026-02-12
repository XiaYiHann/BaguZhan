import { NextFunction, Request, Response } from 'express';
import { config } from '../config/config';
import { HttpError } from '../errors/HttpError';

/**
 * API Key 认证中间件
 * 验证请求头中的 X-Admin-API-Key 是否有效
 *
 * 用于管理后台 API 的身份验证
 */
export const requireApiKey = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const apiKey = req.headers['x-admin-api-key'] as string;

  if (!apiKey) {
    res.status(401).json({
      error: '缺少 API Key',
      message: '请求必须包含 X-Admin-API-Key 请求头',
    });
    return;
  }

  if (apiKey !== config.adminApiKey) {
    res.status(401).json({
      error: '无效的 API Key',
      message: '提供的 API Key 无效',
    });
    return;
  }

  // 标记请求已通过 API Key 认证
  req.isAdmin = true;
  next();
};

/**
 * 创建可选的 API Key 认证中间件
 * 如果提供了 API Key 则验证，否则跳过验证
 */
export const optionalApiKey = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const apiKey = req.headers['x-admin-api-key'] as string;

  if (!apiKey) {
    req.isAdmin = false;
    next();
    return;
  }

  if (apiKey === config.adminApiKey) {
    req.isAdmin = true;
  } else {
    req.isAdmin = false;
  }

  next();
};

// 扩展 Express Request 类型
declare global {
  namespace Express {
    interface Request {
      isAdmin?: boolean;
    }
  }
}
