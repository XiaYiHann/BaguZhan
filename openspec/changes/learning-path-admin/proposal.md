# 学习路径管理

## 为什么

当前学习路径数据硬编码在 Flutter 客户端中，无法动态管理。内容管理员需要一个 API 来创建和编辑学习路径、节点及其关系，同时用户进度需要持久化到数据库。

## 变更内容

- **新增**: 学习路径和节点数据库表
- **新增**: 路径 CRUD API（管理员）
- **新增**: 节点 CRUD API（管理员）
- **新增**: 用户路径进度记录和查询 API
- **修改**: Flutter 客户端从 API 获取路径数据（移除 mock 数据）

## 功能 (Capabilities)

### 新增功能

- `learning-paths`: 学习路径（Learning Path）管理系统，支持路径分类、节点配置和用户进度追踪

### 修改功能

无（当前路径数据仅在客户端 mock，无现有规范）

## 影响

**BFF 服务**:
- `server/src/routes/paths.ts` - 扩展路径路由，添加管理功能
- `server/src/controllers/PathController.ts` - 新增路径管理控制器
- `server/src/repositories/PathRepository.ts` - 新增路径和节点的 CRUD 操作
- `server/src/repositories/PathProgressRepository.ts` - 新增用户路径进度仓储

**Flutter 客户端**:
- `lib/data/repositories/path_repository.dart` - 修改为从 API 获取数据
- `lib/presentation/pages/learning_path_map_page.dart` - 使用 API 数据替换 mock

**数据库**:
- `learning_paths` 表 - 存储学习路径元数据
- `path_nodes` 表 - 存储路径节点（关卡）
- `user_path_progress` 表 - 存储用户在路径上的进度

**API 端点**:
```
# 公开端点（客户端使用）
GET    /api/paths
GET    /api/paths/:id
GET    /api/paths/:id/nodes
GET    /api/paths/:id/progress

# 管理端点（需要 API Key）
POST   /api/admin/paths
PUT    /api/admin/paths/:id
DELETE /api/admin/paths/:id
POST   /api/admin/paths/:id/nodes
PUT    /api/admin/nodes/:id
DELETE /api/admin/nodes/:id
```
