# 题库管理 API - 任务清单

## 1. 认证实现

- [ ] 1.1 创建 `server/src/middleware/apiKeyAuth.ts` 实现 API Key 验证
- [ ] 1.2 在 `server/src/config/config.ts` 添加 `ADMIN_API_KEY` 配置
- [ ] 1.3 创建 POST `/api/admin/login` 端点返回会话 token
- [ ] 1.4 编写 API Key 认证中间件的单元测试

## 2. 题目 CRUD API

- [ ] 2.1 创建 `server/src/controllers/AdminController.ts` 实现管理端点
- [ ] 2.2 在 `QuestionRepository` 添加软删除支持（过滤 `deleted_at`）
- [ ] 2.3 实现 GET `/api/admin/questions` 支持分页和筛选
- [ ] 2.4 实现 POST `/api/admin/questions` 创建题目
- [ ] 2.5 实现 PUT `/api/admin/questions/:id` 更新题目
- [ ] 2.6 实现 DELETE `/api/admin/questions/:id` 软删除题目
- [ ] 2.7 添加题目数据验证（必填字段、选项结构）
- [ ] 2.8 编写题目 CRUD API 的集成测试

## 3. 批量导入功能

- [ ] 3.1 实现 POST `/api/admin/questions/import` 批量导入端点
- [ ] 3.2 添加事务处理确保数据一致性
- [ ] 3.3 添加导入数量限制（最多 100 道题）
- [ ] 3.4 实现部分失败处理（返回 errors 数组）
- [ ] 3.5 编写批量导入功能的测试

## 4. 统计 API

- [ ] 4.1 实现 GET `/api/admin/stats` 端点
- [ ] 4.2 实现按主题分组统计
- [ ] 4.3 实现按难度分组统计
- [ ] 4.4 确保统计数据排除软删除题目
- [ ] 4.5 编写统计 API 的测试

## 5. 数据库迁移

- [ ] 5.1 创建 `server/src/database/migrations/003_add_soft_delete.sql`
- [ ] 5.2 添加 `questions.deleted_at` 字段
- [ ] 5.3 创建 `idx_questions_deleted_at` 索引
- [ ] 5.4 运行迁移并验证

## 6. 路由注册

- [ ] 6.1 创建 `server/src/routes/admin.ts` 路由文件
- [ ] 6.2 在 `server/src/app.ts` 中注册 admin 路由
- [ ] 6.3 为所有 admin 路由添加 API Key 认证中间件
- [ ] 6.4 更新 API 文档或 Postman collection
