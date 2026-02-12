# 题库管理 API - 设计文档

## 上下文

**当前状态**:
- 题库数据存储在 SQLite 数据库中
- 已有基础的 QuestionRepository 和 QuestionService
- 已有公开的题目查询 API (`/questions`)
- 无管理接口，修改数据需要直接操作数据库

**约束**:
- 只需要 REST API，不需要 Web 管理界面
- 简单 API Key 认证即可
- 需要支持批量操作提高效率

## 目标 / 非目标

**目标：**
- 提供完整的题目 CRUD API
- 支持批量导入题目
- 提供题库统计信息
- 实现软删除机制

**非目标：**
- 不实现 Web 管理界面
- 不实现多用户权限系统
- 不实现题目审核流程

## 决策

### 1. 认证方案

**决策**: API Key 通过 HTTP Header 传递

**格式**: `X-Admin-API-Key: <key>`

**理由**:
- 简单易实现
- 适合内部管理场景
- 不需要维护会话状态

**替代方案**:
- JWT Token: 过于复杂，需要过期和刷新机制
- Basic Auth: 内置但安全性较低

### 2. 软删除实现

**决策**: 添加 `deleted_at` 时间戳字段

**理由**:
- 可恢复删除的题目
- 保留历史关联（如答题记录）
- 符合软删除最佳实践

**查询规则**:
- 默认查询过滤 `deleted_at IS NULL`
- 管理端可查询全部（包括已删除）

### 3. 批量导入格式

**决策**: JSON 数组格式

**格式**:
```json
[
  {
    "content": "题目内容",
    "topic": "JavaScript",
    "difficulty": "easy",
    "options": [...],
    "explanation": "解析",
    "mnemonic": "助记",
    "scenario": "场景",
    "tags": ["闭包", "作用域"]
  }
]
```

**理由**:
- JSON 易于生成和解析
- 与现有数据模型一致
- 支持复杂结构（选项、标签等）

### 4. API 响应格式

**决策**: 统一使用标准 HTTP 状态码和 JSON 响应

**成功**:
- `200 OK`: 查询/更新成功
- `201 Created`: 创建成功
- `204 No Content`: 删除成功

**错误**:
- `400 Bad Request`: 请求参数错误
- `401 Unauthorized`: API Key 无效
- `404 Not Found`: 资源不存在
- `422 Unprocessable Entity`: 数据验证失败

## 风险 / 权衡

| 风险 | 缓解措施 |
|------|---------|
| API Key 泄露导致数据被篡改 | 使用环境变量存储，定期轮换 |
| 批量导入可能导致数据不一致 | 使用事务处理，部分失败时全部回滚 |
| 软删除导致查询性能下降 | 在 `deleted_at` 字段上创建索引 |

## 数据库变更

```sql
-- 添加软删除字段
ALTER TABLE questions ADD COLUMN deleted_at TEXT;

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_questions_deleted_at ON questions(deleted_at);
```

## API 端点详细设计

### POST /api/admin/login
**请求**: `{ "apiKey": "baguzhan-admin-secret-2024" }`
**响应**: `{ "token": "admin-session-token", "expiresIn": 86400 }`

### GET /api/admin/questions
**查询参数**: `page`, `limit`, `topic`, `difficulty`, `includeDeleted`
**响应**: 分页的题目列表

### POST /api/admin/questions
**请求**: 题目完整 JSON
**响应**: 创建的题目（含 ID）

### PUT /api/admin/questions/:id
**请求**: 题目更新 JSON
**响应**: 更新后的题目

### DELETE /api/admin/questions/:id
**响应**: 204 No Content

### POST /api/admin/questions/import
**请求**: 题目数组 JSON
**响应**: `{ "imported": 10, "failed": 0, "errors": [] }`

### GET /api/admin/stats
**响应**:
```json
{
  "totalQuestions": 150,
  "byTopic": { "JavaScript": 80, "React": 40, "Vue": 30 },
  "byDifficulty": { "easy": 50, "medium": 60, "hard": 40 }
}
```
