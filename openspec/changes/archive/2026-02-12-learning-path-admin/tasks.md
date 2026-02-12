# 学习路径管理 - 任务清单

## 1. 数据库实现

- [x] 1.1 创建 `server/src/database/migrations/004_add_learning_paths.sql`
- [x] 1.2 创建 `learning_paths` 表
- [x] 1.3 创建 `path_nodes` 表
- [x] 1.4 创建 `user_path_progress` 表
- [x] 1.5 添加外键约束和索引
- [x] 1.6 创建初始数据脚本（seed data）

## 2. BFF 后端 - Repository 层

- [x] 2.1 创建 `server/src/repositories/PathRepository.ts`
- [x] 2.2 实现路径 CRUD 方法（getByTechStack, create, update, delete）
- [x] 2.3 实现节点 CRUD 方法（getByPathId, createNode, updateNode, deleteNode）
- [x] 2.4 创建 `server/src/repositories/PathProgressRepository.ts`
- [x] 2.5 实现进度记录方法（recordCompletion, getByUserAndPath）
- [x] 2.6 实现节点解锁逻辑（unlockNextNodes）

## 3. BFF 后端 - Service 层

- [x] 3.1 创建 `server/src/services/PathService.ts`
- [x] 3.2 实现获取路径及节点方法
- [x] 3.3 实现获取用户进度方法（含自动初始化）
- [x] 3.4 实现节点完成处理方法（自动解锁下一节点）
- [x] 3.5 添加环状依赖检测（防止死锁）

## 4. BFF 后端 - API 路由

- [x] 4.1 实现公开端点 GET `/api/paths`
- [x] 4.2 实现公开端点 GET `/api/paths/:id`
- [x] 4.3 实现公开端点 GET `/api/paths/:id/nodes`
- [x] 4.4 实现公开端点 GET `/api/paths/:id/progress`（需要设备 ID）
- [x] 4.5 实现管理端点 POST `/api/admin/paths`
- [x] 4.6 实现管理端点 PUT `/api/admin/paths/:id`
- [x] 4.7 实现管理端点 DELETE `/api/admin/paths/:id`
- [x] 4.8 实现管理端点 POST `/api/admin/paths/:id/nodes`
- [x] 4.9 实现管理端点 PUT `/api/admin/nodes/:id`
- [x] 4.10 实现管理端点 DELETE `/api/admin/nodes/:id`
- [x] 4.11 在 `server/src/app.ts` 中注册新路由

## 5. Flutter 客户端适配

- [x] 5.1 创建 `lib/data/models/learning_path_model.dart`
- [x] 5.2 更新 `lib/data/repositories/path_repository.dart` 调用 API
- [x] 5.3 更新 `lib/data/repositories/api_path_repository.dart` 实现网络请求
- [x] 5.4 修改 `lib/presentation/pages/learning_path_map_page.dart` 使用 API 数据
- [x] 5.5 移除页面中的 mock 数据

## 6. 类型定义

- [x] 6.1 创建 `server/src/types/learningPath.ts`
- [x] 6.2 定义 Path, PathNode, PathProgress 接口
- [x] 6.3 确保与 Flutter 端模型一致

## 7. 测试

- [x] 7.1 编写 PathRepository 单元测试
- [x] 7.2 编写节点解锁逻辑测试
- [x] 7.3 编写路径 API 集成测试
- [x] 7.4 编写进度 API 集成测试
- [x] 7.5 端到端测试：完整路径进度流程

## 8. 数据初始化

- [x] 8.1 准备初始路径数据（JavaScript, React, Vue）
- [x] 8.2 准备初始节点数据（每个路径 5-10 个节点）
- [x] 8.3 执行数据导入脚本
- [x] 8.4 验证导入数据完整性
