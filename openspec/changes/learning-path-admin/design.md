# 学习路径管理 - 设计文档

## 上下文

**当前状态**:
- Flutter 客户端已有学习路径 UI（`learning_path_map_page.dart`）
- 路径数据为硬编码的 mock 数据
- 已有基础的路由模型（`PathNodeModel`, `PathCategoryModel`）
- BFF 端有基础的路由服务但数据不持久化

**约束**:
- 需要保持与现有 Flutter UI 的兼容性
- 节点之间存在依赖关系（先修节点）
- 需要支持用户进度追踪

## 目标 / 非目标

**目标：**
- 将路径和节点数据持久化到数据库
- 提供管理 API 来创建和管理路径
- 记录和查询用户在路径上的进度
- 自动处理节点解锁逻辑

**非目标：**
- 不实现路径推荐算法
- 不实现多分支路径选择
- 不实现实时多人协作

## 决策

### 1. 数据模型设计

**决策**: 三表设计 - paths, nodes, progress

**表结构**:
```sql
-- 学习路径表
learning_paths (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  description TEXT,
  tech_stack TEXT,      -- 如 "javascript", "react", "vue"
  sort_order INTEGER DEFAULT 0,
  created_at TEXT
)

-- 路径节点表
path_nodes (
  id TEXT PRIMARY KEY,
  path_id TEXT NOT NULL,
  title TEXT NOT NULL,
  icon TEXT,
  color TEXT,           -- primary, secondary, accent, error, diamond
  status TEXT DEFAULT 'locked',
  order INTEGER NOT NULL,
  prerequisite_node_id TEXT,  -- 前置节点ID
  question_ids TEXT,     -- JSON array
  estimated_minutes INTEGER,
  FOREIGN KEY (path_id) REFERENCES learning_paths(id) ON DELETE CASCADE
)

-- 用户路径进度表
user_path_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  path_id TEXT NOT NULL,
  node_id TEXT NOT NULL,
  status TEXT DEFAULT 'locked',  -- locked, current, completed
  completed_at TEXT,
  UNIQUE(user_id, node_id)
)
```

**理由**:
- 分离路径定义和用户进度
- 支持前置节点依赖关系
- 用户与路径的关系独立记录

### 2. 节点解锁逻辑

**决策**: 基于前置节点完成状态自动解锁

**规则**:
1. 首节点默认解锁
2. 节点状态 = `completed` 时，检查是否有依赖此节点的其他节点
3. 将依赖节点的状态从 `locked` 改为 `unlocked`

**实现位置**: BFF 端 `PathService` 方法

### 3. 进度查询策略

**决策**: 惰性创建进度记录

**流程**:
1. 用户访问路径时，检查 `user_path_progress`
2. 如果不存在记录，自动创建首节点为 `current`
3. 返回完整路径数据 + 用户进度状态

**理由**:
- 减少不必要的数据库写入
- 首次访问即可获得完整状态

### 4. 题目关联方式

**决策**: 节点存储题目 ID 数组

**格式**: JSON 字符串 `["q1", "q2", "q3"]`

**理由**:
- 灵活：同一题目可被多个节点使用
- 简单：不需要额外的关联表
- 与现有 Flutter 代码兼容

## 风险 / 权衡

| 风险 | 缓解措施 |
|------|---------|
| 前置节点形成环导致死锁 | API 验证时检测环状依赖 |
| 删除节点导致进度记录失效 | 软删除节点，保留历史记录 |
| 题目 ID 变更导致关联失效 | 题目使用稳定 ID |

## 迁移计划

1. **数据库迁移**:
   - 创建三张新表
   - 导入初始路径和节点数据

2. **BFF 端**:
   - 实现新的 Repository 和 Service
   - 添加管理 API 路由
   - 添加进度查询 API

3. **Flutter 端**:
   - 更新 Repository 调用 API
   - 移除 mock 数据
   - 适配新的响应格式

## API 端点详细设计

### 公开端点

**GET /api/paths**
- 查询参数: `tech_stack` (可选)
- 响应: 路径列表（不包含节点详情）

**GET /api/paths/:id**
- 响应: 单个路径详情 + 所有节点

**GET /api/paths/:id/nodes**
- 响应: 路径下的所有节点（含用户解锁状态）

**GET /api/paths/:id/progress**
- Header: `X-Device-ID`
- 响应: 用户在该路径上的进度统计

### 管理端点

**POST /api/admin/paths**
- 请求: 路径创建 JSON
- 响应: 创建的路径

**PUT /api/admin/paths/:id**
- 请求: 路径更新 JSON
- 响应: 更新后的路径

**DELETE /api/admin/paths/:id**
- 级联删除所有关联节点

**POST /api/admin/paths/:id/nodes**
- 请求: 节点创建 JSON
- 响应: 创建的节点

**PUT /api/admin/nodes/:id**
- 请求: 节点更新 JSON
- 响应: 更新后的节点

**DELETE /api/admin/nodes/:id**
- 软删除节点
