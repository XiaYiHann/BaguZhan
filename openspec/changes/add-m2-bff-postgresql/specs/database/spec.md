# 数据库规范

## ADDED Requirements

### Requirement: 数据库 MUST 存储题目和选项的完整信息

数据库 MUST 包含 questions 和 options 两张表，支持存储题目内容、主题、难度、解析、助记、场景、标签等信息。

**最佳实践基线**：
- better-sqlite3 预编译语句 - [Binding Parameters](https://context7.com/wiselibs/better-sqlite3/llms.txt)
- better-sqlite3 事务支持 - [Execute Transaction](https://context7.com/wiselibs/better-sqlite3/llms.txt)
- SQLite 测试最佳实践 - [SQLite Testing](https://atdatabases.org/docs/sqlite-test)

#### Scenario: 创建题目表

**TDD 测试 Schema 创建**：
```typescript
// database/migrations/001-create-questions.test.ts
describe('Question Schema Migration', () => {
  it('should create questions table with all columns', () => {
    const columns = db.prepare(`
      SELECT sql FROM sqlite_master
      WHERE type='table' AND name='questions'
    `).all();

    const tableInfo = db.prepare(`PRAGMA table_info(questions)`).all();

    expect(tableInfo).toContainEqual(
      expect.objectContaining({ name: 'id', type: 'TEXT' })
    );
    expect(tableInfo).toContainEqual(
      expect.objectContaining({ name: 'difficulty', type: 'TEXT' })
    );
  });
});
```

- **给定** 数据库已初始化
- **当** 执行 Schema 创建脚本
- **那么** questions 表应包含以下字段：
  - `id` TEXT PRIMARY KEY
  - `content` TEXT NOT NULL
  - `topic` TEXT NOT NULL
  - `difficulty` TEXT NOT NULL (值为 'easy', 'medium', 'hard' 之一)
  - `explanation` TEXT
  - `mnemonic` TEXT
  - `scenario` TEXT
  - `tags` TEXT (JSON 数组字符串)
  - `created_at` TIMESTAMP

#### Scenario: 创建选项表

- **给定** 数据库已初始化
- **当** 执行 Schema 创建脚本
- **那么** options 表应包含以下字段：
  - `id` TEXT PRIMARY KEY
  - `question_id` TEXT NOT NULL (外键引用 questions.id)
  - `option_text` TEXT NOT NULL
  - `option_order` INTEGER NOT NULL (0-3)
  - `is_correct` BOOLEAN NOT NULL (默认 FALSE)
  - UNIQUE(question_id, option_order) 约束

#### Scenario: 级联删除

**TDD 测试外键约束**：
```typescript
it('should cascade delete options when question is deleted', () => {
  const questionId = 'test-1';

  // Insert question with options
  db.prepare('INSERT INTO questions (id, content, topic) VALUES (?, ?, ?)').run(questionId, 'Test', 'JavaScript');
  db.prepare('INSERT INTO options (id, question_id, option_text) VALUES (?, ?, ?)').run('opt-1', questionId, 'Option 1');

  // Delete question
  db.prepare('DELETE FROM questions WHERE id = ?').run(questionId);

  // Verify options are also deleted
  const remaining = db.prepare('SELECT COUNT(*) as count FROM options WHERE question_id = ?').get(questionId);
  expect(remaining.count).toBe(0);
});
```

- **给定** 数据库中存在题目和对应的选项
- **当** 删除一道题目
- **那么** 该题目的所有选项应自动删除

---

### Requirement: 数据库 MUST 优化查询性能

数据库 MUST 在常用查询字段上建立索引，确保筛选和随机查询的性能。

**最佳实践基线**：
- 索引优化最佳实践 - [Top 10 PostgreSQL best practices for 2025](https://www.instaclustr.com/education/postgresql/top-10-postgresql-best-practices-for-2025/)

#### Scenario: 主题筛选索引

**TDD 验证索引使用**：
```typescript
it('should use index when filtering by topic', () => {
  // SQLite EXPLAIN QUERY PLAN
  const plan = db.prepare('EXPLAIN QUERY PLAN SELECT * FROM questions WHERE topic = ?').get('JavaScript');

  // Check that index is used (implementation varies by SQLite)
  expect(plan).toBeDefined();
});
```

- **给定** questions 表已创建
- **当** 查询 `SELECT * FROM questions WHERE topic = 'JavaScript'`
- **那么** 查询应使用 `idx_questions_topic` 索引

#### Scenario: 难度筛选索引

- **给定** questions 表已创建
- **当** 查询 `SELECT * FROM questions WHERE difficulty = 'easy'`
- **那么** 查询应使用 `idx_questions_difficulty` 索引

#### Scenario: 复合条件索引

- **给定** questions 表已创建
- **当** 查询 `SELECT * FROM questions WHERE topic = 'JavaScript' AND difficulty = 'easy'`
- **那么** 查询应使用 `idx_questions_topic_difficulty` 复合索引

---

### Requirement: 数据库 MUST 支持随机查询

数据库 MUST 支持按条件筛选后随机返回指定数量的题目。

**最佳实践基线**：
- PostgreSQL 随机查询 - [PostgreSQL 随机抽题](https://blog.csdn.net/luansj/article/details/118939166)

#### Scenario: 简单随机查询

**TDD 测试随机性**：
```typescript
it('should return random questions on each call', () => {
  const results1 = db.prepare('SELECT * FROM questions WHERE topic = ? ORDER BY RANDOM() LIMIT 3').all('JavaScript');
  const results2 = db.prepare('SELECT * FROM questions WHERE topic = ? ORDER BY RANDOM() LIMIT 3').all('JavaScript');

  expect(results1).not.toEqual(results2);
  expect(results1).toHaveLength(3);
  expect(results2).toHaveLength(3);
});
```

- **给定** 数据库中有 JavaScript 题目 10 道
- **当** 执行 `SELECT * FROM questions WHERE topic = 'JavaScript' ORDER BY RANDOM() LIMIT 5`
- **那么** 返回 5 道随机题目
- **并且** 每次执行返回的题目应该不同

#### Scenario: 带条件的随机查询

- **给定** 数据库中有 JavaScript 题目，包含 easy 和 medium 难度
- **当** 执行 `SELECT * FROM questions WHERE topic = 'JavaScript' AND difficulty = 'easy' ORDER BY RANDOM() LIMIT 3`
- **那么** 返回 3 道 easy 难度的随机题目

#### Scenario: 随机查询性能

**TDD 性能测试**：
```typescript
it('should complete random query within 100ms', () => {
  const start = Date.now();

  db.prepare('SELECT * FROM questions WHERE topic = ? ORDER BY RANDOM() LIMIT 10').all('JavaScript');

  const duration = Date.now() - start;
  expect(duration).toBeLessThan(100);
});
```

- **给定** 数据库中有 1000 道题目
- **当** 执行随机查询 LIMIT 10
- **那么** 查询应在 100ms 内完成（使用索引优化）

---

### Requirement: 数据库 MUST 提供迁移和种子数据

数据库 MUST 支持版本化的 Schema 迁移，并提供初始种子数据用于开发测试。

**最佳实践基线**：
- Drizzle ORM 迁移模式 - [Database Migration and Seeding](https://github.com/wiselibs/better-sqlite3/blob/master/docs/api.md)
- 数据库种子最佳实践 - [MikroORM Seeding](https://github.com/mikro-orm/mikro-orm/main/docs/versioned_docs/version-6.1/seeding.md)
- In-memory 测试数据库 - [createTestDb function](https://raw.githubusercontent.com/Matt-Dionis/claude-code-configs/main/configurations/databases/drizzle/README.md)

#### Scenario: 执行数据库迁移

**TDD 测试迁移**：
```typescript
// test/database/migration.test.ts
describe('Database Migrations', () => {
  it('should create all tables from migrations', () => {
    const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all();

    expect(tables).toContainEqual(
      expect.objectContaining({ name: 'questions' })
    );
    expect(tables).toContainEqual(
      expect.objectContaining({ name: 'options' })
    );
  });
});
```

- **给定** 数据库文件不存在
- **当** 执行 `npm run db:migrate`
- **那么** 创建数据库文件并执行所有迁移脚本

#### Scenario: 加载种子数据

**TDD 验证种子数据**：
```typescript
it('should seed initial questions', () => {
  const count = db.prepare('SELECT COUNT(*) as count FROM questions').get();

  expect(count.count).toBeGreaterThanOrEqual(8);

  // Verify topics exist
  const topics = db.prepare('SELECT DISTINCT topic FROM questions').all();
  const topicNames = topics.map(row => row.topic);
  expect(topicNames).toContain('JavaScript');
  expect(topicNames).toContain('React');
  expect(topicNames).toContain('Vue');
});
```

- **给定** 数据库 Schema 已创建
- **当** 执行 `npm run db:seed`
- **那么** 插入至少 8 道预置题目
- **并且** 包含 JavaScript、React、Vue 等主题
- **并且** 每题有 4 个选项，1 个正确答案

#### Scenario: 重置数据库

**TDD 测试重置功能**：
```typescript
it('should reset database to clean state', () => {
  // Insert some test data
  db.prepare('INSERT INTO questions (id, content, topic) VALUES (?, ?, ?)').run('test', 'Test', 'JavaScript');

  // Run reset
  resetDatabase();

  // Verify empty
  const count = db.prepare('SELECT COUNT(*) as count FROM questions').get();
  expect(count.count).toBe(0);
});
```

- **给定** 数据库中有数据
- **当** 执行 `npm run db:reset`
- **那么** 删除数据库并重新执行迁移和种子数据

---

### Requirement: 数据库测试 MUST 使用隔离的测试数据库

数据库测试 MUST 使用内存数据库或独立的测试文件，避免污染开发数据库。

**最佳实践基线**：
- In-memory SQLite 测试 - [createTestDb function](https://raw.githubusercontent.com/Matt-Dionis/claude-code-configs/main/configurations/databases/drizzle/README.md)
- 测试隔离最佳实践 - [Setup and Teardown for Database in Jest Tests](https://raw.githubusercontent.com/superbasicstudio/claude-conductor/main/templates/TEST.md)

#### Scenario: 使用内存数据库进行测试

**TDD 测试数据库隔离**：
```typescript
describe('QuestionRepository', () => {
  let db: Database;

  beforeEach(() => {
    // Create in-memory database for each test
    db = new Database(':memory:');
    migrateTestDb(db);
  });

  afterEach(() => {
    db.close();
  });

  it('should use in-memory database for tests', () => {
    const dbPath = db.name; // better-sqlite3 property
    expect(dbPath).toBe(':memory:');
  });
});
```

- **给定** 正在运行测试套件
- **当** 测试需要数据库连接
- **那么** 使用 `:memory:` 创建临时内存数据库
- **并且** 测试结束后数据库自动清理

#### Scenario: 每个测试前重置数据库状态

- **给定** 测试套件有多个测试
- **当** 每个 test 执行前
- **那么** 数据库重置到已知的干净状态
- **并且** 测试之间互不影响
