# 设备 ID 认证

## 为什么

当前系统缺少用户识别机制，导致用户数据（答题记录、错题本、学习进度）无法跨会话持久化和关联。在设备管理后台和题库管理之前，必须先建立用户身份识别基础。

## 变更内容

- **新增**: 设备 ID 生成和持久化机制（Flutter 端）
- **新增**: 自动附加设备 ID 到所有 API 请求的拦截器
- **新增**: BFF 端设备 ID 验证中间件
- **修改**: 所有用户数据 API (`/api/progress`, `/api/wrong-book`, `/api/answers`) 要求设备 ID

## 功能 (Capabilities)

### 新增功能

- `device-id-auth`: 基于设备唯一标识符的匿名用户认证系统，支持用户数据跨会话持久化

### 修改功能

- `user-progress`: 现有用户进度 API 需要设备 ID 参数
- `wrong-book`: 现有错题本 API 需要设备 ID 参数
- `answer-recording`: 现有答题记录 API 需要设备 ID 参数

## 影响

**Flutter 客户端**:
- `lib/core/device_id.dart` - 新增设备 ID 生成/存储
- `lib/network/interceptors/auth_interceptor.dart` - 新增请求拦截器
- `lib/data/repositories/*_repository.dart` - 修改以使用设备 ID

**BFF 服务**:
- `server/src/middleware/deviceId.ts` - 新增设备 ID 验证中间件
- `server/src/routes/userProgress.ts` - 修改路由要求设备 ID
- `server/src/repositories/UserProgressRepository.ts` - 使用设备 ID 作为用户标识

**数据库**:
- `user_progress` 表 - `user_id` 字段将存储设备 ID
- `wrong_books` 表 - `user_id` 字段将存储设备 ID
- `user_answers` 表 - `user_id` 字段将存储设备 ID
