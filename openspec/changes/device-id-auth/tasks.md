# 设备 ID 认证 - 任务清单

## 1. Flutter 客户端实现

- [ ] 1.1 添加 `uuid` 包依赖到 `pubspec.yaml`
- [ ] 1.2 创建 `lib/core/device_id.dart` 实现设备 ID 生成和存储
- [ ] 1.3 创建 `lib/network/interceptors/auth_interceptor.dart` 实现请求拦截器
- [ ] 1.4 更新 `ApiClient` 初始化，添加设备 ID 拦截器
- [ ] 1.5 更新 `ApiUserProgressRepository` 使用设备 ID
- [ ] 1.6 更新 `ApiQuestionRepository` 使用设备 ID
- [ ] 1.7 编写设备 ID 功能的单元测试

## 2. BFF 后端实现

- [ ] 2.1 创建 `server/src/middleware/deviceId.ts` 实现设备 ID 验证中间件
- [ ] 2.2 更新 `server/src/routes/userProgress.ts` 添加设备 ID 要求
- [ ] 2.3 更新 `server/src/repositories/UserProgressRepository.ts` 使用设备 ID 作为用户标识
- [ ] 2.4 创建数据库迁移脚本 `server/src/database/migrations/002_add_device_id.sql`
- [ ] 2.5 编写设备 ID 中间件的集成测试

## 3. 数据库迁移

- [ ] 3.1 确认 `user_answers` 表有 `user_id` 字段
- [ ] 3.2 确认 `wrong_books` 表有 `user_id` 字段
- [ ] 3.3 确认 `user_progress` 表有 `user_id` 字段
- [ ] 3.4 创建 `user_id` 字段索引
- [ ] 3.5 运行数据库迁移并验证

## 4. 测试与验证

- [ ] 4.1 编写 Flutter 端设备 ID 生成测试
- [ ] 4.2 编写 Flutter 端拦截器测试
- [ ] 4.3 编写 BFF 端设备 ID 验证测试
- [ ] 4.4 端到端测试：验证用户数据正确关联
- [ ] 4.5 手动测试：清除应用数据后重新登录
