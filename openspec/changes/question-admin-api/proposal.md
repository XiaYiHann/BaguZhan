# 题库管理 API

## 为什么

当前题库数据只能通过直接操作数据库或导入脚本来管理，缺少便捷的管理接口。内容管理员需要一个 REST API 来创建、编辑和管理题目，而不需要直接访问数据库。

## 变更内容

- **新增**: 管理员 API Key 认证机制
- **新增**: 题目 CRUD API (创建、读取、更新、删除)
- **新增**: 批量导入题目 API
- **新增**: 题库统计信息 API
- **新增**: 软删除机制（题目标记为已删除而非物理删除）

## 功能 (Capabilities)

### 新增功能

- `admin-auth`: 基于 API Key 的管理员认证系统
- `question-crud`: 题目的完整 CRUD 操作 API
- `question-bulk-import`: 批量导入题目的 API
- `question-stats`: 题库统计信息查询 API

### 修改功能

无

## 影响

**BFF 服务**:
- `server/src/routes/admin.ts` - 新增管理后台路由
- `server/src/middleware/apiKeyAuth.ts` - 新增 API Key 验证中间件
- `server/src/controllers/AdminController.ts` - 新增管理控制器
- `server/src/repositories/QuestionRepository.ts` - 新增软删除支持

**数据库**:
- `questions` 表 - 添加 `deleted_at` 字段支持软删除

**环境变量**:
- `ADMIN_API_KEY` - 新增管理员 API Key 配置

**API 端点**:
```
POST   /api/admin/login
GET    /api/admin/questions
POST   /api/admin/questions
PUT    /api/admin/questions/:id
DELETE /api/admin/questions/:id
POST   /api/admin/questions/import
GET    /api/admin/stats
```
