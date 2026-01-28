# M2 架构设计文档

## 系统架构概览

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Flutter App   │────────▶│  BFF (Node.js)  │────────▶│  SQLite/PG DB   │
│                 │ HTTP    │                 │ SQL     │                 │
│  - QuestionPage │         │  - /questions   │         │  - questions    │
│  - Provider     │         │  - /questions/  │         │  - options      │
│  - Dio Client   │         │    random       │         │  - indexes      │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

## 技术决策

### 1. 为什么选择 REST API 而非 GraphQL

**优势：**
- 简单直接，MVP 阶段学习成本低
- Flutter Dio 包成熟稳定
- 缓存策略更简单（HTTP 缓存头）
- 调试友好（可用 curl/Postman 直接测试）

**权衡：**
- GraphQL 的类型安全和按需获取在未来数据模型复杂时可考虑
- 当前题目模型相对固定，REST 足够

### 2. 为什么选择 SQLite 开发环境

**优势：**
- 零配置，无需安装 PostgreSQL 服务
- 文件数据库，便于版本控制和测试
- 后续迁移到 PostgreSQL 只需修改连接字符串
- 表结构兼容，SQL 语法基本一致

**迁移路径：**
```typescript
// 开发环境
const dbPath = process.env.NODE_ENV === 'test' ? ':memory:' : './data.db';

// 生产环境（切换时）
// const dbConfig = {
//   host: process.env.DB_HOST,
//   database: process.env.DB_NAME,
//   // ...
// };
```

### 3. Clean Architecture 分层

```
┌─────────────────────────────────────────────────────┐
│                    Routes Layer                      │
│  (定义端点、验证参数、调用 Controller)                │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                 Controllers Layer                    │
│  (处理 HTTP 请求/响应、调用 Service)                 │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                  Services Layer                      │
│  (业务逻辑、数据组合、事务边界)                       │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│               Repositories Layer                     │
│  (数据库访问、SQL 查询、数据映射)                     │
└─────────────────────────────────────────────────────┘
```

**优势：**
- 每层职责单一，易于测试
- 依赖注入，可替换实现
- 符合 SOLID 原则

## 数据库设计

### 表结构

```sql
-- 题目表
CREATE TABLE questions (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  topic TEXT NOT NULL,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  explanation TEXT,
  mnemonic TEXT,
  scenario TEXT,
  tags TEXT, -- JSON array: '["event-loop", "async"]'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 选项表
CREATE TABLE options (
  id TEXT PRIMARY KEY,
  question_id TEXT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  option_order INTEGER NOT NULL CHECK (option_order BETWEEN 0 AND 3),
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(question_id, option_order)
);

-- 索引优化查询
CREATE INDEX idx_questions_topic ON questions(topic);
CREATE INDEX idx_questions_difficulty ON questions(difficulty);
CREATE INDEX idx_questions_topic_difficulty ON questions(topic, difficulty);
CREATE INDEX idx_options_question_id ON options(question_id);
```

### 随机查询优化

```sql
-- 方案1：简单随机（小数据集）
SELECT * FROM questions
WHERE topic = ? AND difficulty = ?
ORDER BY RANDOM()
LIMIT ?;

-- 方案2：预筛选后随机（大数据集，未来优化）
WITH filtered AS (
  SELECT id FROM questions
  WHERE topic = ? AND difficulty = ?
)
SELECT q.* FROM questions q
JOIN filtered f ON q.id = f.id
ORDER BY RANDOM()
LIMIT ?;
```

## API 设计

### 端点定义

| 方法 | 端点 | 参数 | 响应 |
|------|------|------|------|
| GET | `/health` | - | `{ status: "ok" }` |
| GET | `/questions` | `topic`, `difficulty`, `limit`, `offset` | Question[] |
| GET | `/questions/random` | `topic`, `difficulty`, `count` | Question[] |
| GET | `/questions/:id` | - | Question |

### 响应格式

```typescript
// Question
interface Question {
  id: string;
  content: string;
  topic: string;
  difficulty: 'easy' | 'medium' | 'hard';
  explanation?: string;
  mnemonic?: string;
  scenario?: string;
  tags?: string[];
  options: Option[];
}

// Option
interface Option {
  id: string;
  questionId: string;
  optionText: string;
  optionOrder: number;
  isCorrect: boolean; // 仅在详细查询时返回
}
```

### 错误处理

```typescript
// 统一错误响应格式
interface ErrorResponse {
  error: string;
  message: string;
  details?: Record<string, unknown>;
}

// HTTP 状态码
400 - 参数验证失败
404 - 资源不存在
500 - 服务器错误
```

## Flutter 集成架构

### Repository 抽象

```dart
abstract class QuestionRepository {
  Future<List<QuestionModel>> getQuestions({
    required String topic,
    String? difficulty,
    int limit = 10,
    int offset = 0,
  });

  Future<List<QuestionModel>> getRandomQuestions({
    required String topic,
    String? difficulty,
    int count = 5,
  });

  Future<QuestionModel?> getQuestionById(String id);
}

// API 实现
class ApiQuestionRepository implements QuestionRepository {
  final Dio _dio;

  ApiQuestionRepository({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // 添加拦截器
    dio.interceptors.addAll([
      LogInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
```

### Provider 状态管理

```dart
enum QuestionState { initial, loading, loaded, error }

class QuestionProvider extends ChangeNotifier {
  final QuestionRepository repository;

  QuestionState _state = QuestionState.initial;
  String? _errorMessage;

  // 添加加载状态
  Future<void> loadQuestions(String topic) async {
    _state = QuestionState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final questions = await repository.getQuestions(topic: topic);
      // ... 处理数据
      _state = QuestionState.loaded;
    } catch (e) {
      _state = QuestionState.error;
      _errorMessage = _parseError(e);
    }

    notifyListeners();
  }
}
```

## 测试策略

### 后端测试

```typescript
// 集成测试
describe('GET /questions', () => {
  it('should return filtered questions', async () => {
    const response = await request(app)
      .get('/questions?topic=JavaScript&difficulty=easy')
      .expect(200);

    expect(response.body).toHaveLength(3);
    expect(response.body[0].topic).toBe('JavaScript');
  });

  it('should return 404 for invalid topic', async () => {
    await request(app)
      .get('/questions?topic=Invalid')
      .expect(404);
  });
});
```

### 前端测试

```dart
// 使用 Mock API
void main() {
  late MockQuestionRepository mockRepository;

  setUp(() {
    mockRepository = MockQuestionRepository();
  });

  testWidgets('shows loading then questions', (tester) async {
    when(mockRepository.getQuestions(topic: 'JavaScript'))
      .thenAnswer((_) async => [question1, question2]);

    // ... 测试逻辑
  });
}
```

## 安全考虑（M2 暂不实现，但预留扩展）

### 未来认证方案
- JWT Bearer Token
- 刷新 Token 机制
- CORS 白名单配置

### 未来限流方案
- 按 IP 限流
- 按用户限流（认证后）
- Redis 计数器

## 部署架构（M2 本地开发）

```
┌─────────────────────────────────────────┐
│           开发环境                       │
│                                          │
│  ┌─────────────┐      ┌─────────────┐  │
│  │  Flutter    │      │  Node.js    │  │
│  │  (Simulator)│◀────▶│  BFF        │  │
│  └─────────────┘ HTTP └─────────────┘  │
│                             │           │
│                             ▼           │
│                      ┌─────────────┐   │
│                      │  SQLite     │   │
│                      │  data.db    │   │
│                      └─────────────┘   │
└─────────────────────────────────────────┘
```

## 性能优化要点

1. **数据库索引**：已添加 topic、difficulty 复合索引
2. **连接池**：M2 单连接足够，M3 再优化
3. **查询缓存**：暂不实现，M4 考虑 Redis
4. **分页**：支持 `limit` + `offset` 参数
5. **HTTP 缓存**：未来可添加 `ETag` / `Last-Modified`
