# 八股斩 BFF 服务

八股斩（BaguZhan）的 Backend for Frontend (BFF) 服务，为 Flutter 应用提供 RESTful API。

## 技术栈

- **Node.js** + **TypeScript**
- **Express** - Web 框架
- **SQLite** - 开发环境数据库（可迁移至 PostgreSQL）
- **Clean Architecture** - 分层架构

## 项目结构

```
server/
├── src/
│   ├── routes/           # 路由定义
│   ├── controllers/      # 请求处理
│   ├── services/         # 业务逻辑
│   ├── repositories/     # 数据访问
│   ├── middlewares/      # 中间件
│   ├── database/         # 数据库连接和迁移
│   ├── config/           # 配置
│   └── types/            # TypeScript 类型
├── tests/                # 测试文件
└── data/                 # SQLite 数据库文件
```

## 快速开始

### 安装依赖

```bash
npm install
```

### 数据库初始化

```bash
# 运行迁移（创建表结构）
npm run db:migrate

# 导入种子数据
npm run db:seed
```

### 启动服务

```bash
# 开发模式（热重载）
npm run dev

# 生产模式
npm run build
npm start
```

服务默认运行在 `http://localhost:3000`

## API 端点

### 健康检查

```http
GET /health
```

响应：
```json
{
  "status": "ok"
}
```

### 获取题目列表

```http
GET /questions?topic={topic}&difficulty={difficulty}&limit={limit}&offset={offset}
```

参数：
- `topic` (可选): 主题筛选，如 `JavaScript`, `React`
- `difficulty` (可选): 难度筛选，`easy`, `medium`, `hard`
- `limit` (可选): 返回数量，默认 10
- `offset` (可选): 分页偏移，默认 0

响应：
```json
[
  {
    "id": "js-1",
    "content": "题目内容",
    "topic": "JavaScript",
    "difficulty": "easy",
    "explanation": "解析",
    "mnemonic": "口诀",
    "scenario": "应用场景",
    "tags": ["event-loop", "async"],
    "options": [
      {
        "id": "opt-1",
        "questionId": "js-1",
        "optionText": "选项 A",
        "optionOrder": 0,
        "isCorrect": true
      }
    ]
  }
]
```

### 获取随机题目

```http
GET /questions/random?topic={topic}&difficulty={difficulty}&count={count}
```

参数：
- `topic` (可选): 主题筛选
- `difficulty` (可选): 难度筛选
- `count` (可选): 返回数量，默认 5

### 获取单个题目

```http
GET /questions/:id
```

响应：单个题目对象

## 错误处理

统一错误响应格式：

```json
{
  "error": "错误类型",
  "message": "错误描述"
}
```

HTTP 状态码：
- `200` - 成功
- `400` - 请求参数错误
- `404` - 资源不存在
- `500` - 服务器内部错误

## 测试

```bash
# 运行所有测试
npm test

# 监听模式
npm run test:watch
```

## 代码规范

```bash
# 运行 ESLint
npm run lint

# 格式化代码
npm run format
```

## 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `PORT` | 服务端口 | `3000` |
| `NODE_ENV` | 运行环境 | `development` |
| `DB_PATH` | 数据库文件路径 | `./database/data.db` |

## 数据库 Schema

### questions 表

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT PRIMARY KEY | 题目 ID |
| `content` | TEXT | 题目内容 |
| `topic` | TEXT | 主题 |
| `difficulty` | TEXT | 难度 |
| `explanation` | TEXT | 解析 |
| `mnemonic` | TEXT | 口诀 |
| `scenario` | TEXT | 应用场景 |
| `tags` | TEXT (JSON) | 标签数组 |
| `created_at` | TIMESTAMP | 创建时间 |

### options 表

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT PRIMARY KEY | 选项 ID |
| `question_id` | TEXT FK | 关联题目 |
| `option_text` | TEXT | 选项文本 |
| `option_order` | INTEGER | 选项顺序 |
| `is_correct` | BOOLEAN | 是否正确 |

## 性能优化

- 已添加索引：`topic`, `difficulty`, `(topic, difficulty)` 复合索引
- 随机查询使用 `ORDER BY RANDOM() LIMIT ?`
- 支持分页查询

## 许可证

MIT
