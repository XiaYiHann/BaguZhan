import { Request, Response, NextFunction } from 'express';

/**
 * 设备 ID 验证中间件
 * 验证请求头中的 X-Device-ID 是否为有效的 UUID 格式
 *
 * UUID 格式: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (8-4-4-4-12)
 */
export const validateDeviceId = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const deviceId = req.headers['x-device-id'] as string;

  if (!deviceId) {
    res.status(400).json({
      error: '缺少设备 ID',
      message: '请求必须包含 X-Device-ID 请求头',
    });
    return;
  }

  // UUID 通用格式正则表达式 (8-4-4-4-12 十六进制数字)
  const uuidRegex =
    /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;

  if (!uuidRegex.test(deviceId)) {
    res.status(400).json({
      error: '无效的设备 ID',
      message: 'X-Device-ID 必须是有效的 UUID 格式',
    });
    return;
  }

  // 将设备 ID 添加到请求对象，供后续处理使用
  req.deviceId = deviceId;
  next();
};

// 扩展 Express Request 类型
declare global {
  namespace Express {
    interface Request {
      deviceId?: string;
    }
  }
}
