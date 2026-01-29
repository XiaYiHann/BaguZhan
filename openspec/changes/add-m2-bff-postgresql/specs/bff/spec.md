# BFF 后端规范

## ADDED Requirements

### Requirement: BFF 服务 MUST 提供 RESTful API 端点供 Flutter 客户端调用

BFF (Backend For Frontend) MUST 提供标准化的 HTTP RESTful API，支持题目查询、筛选、随机出题等功能。

**最佳实践基线**：
- Express.js 官方文档 - [Architecture & Features](https://context7.com/expressjs/express/llms.txt)
- Express.js 路由模块化模式 - [Create Modular Route Handlers](https://context7.com/expressjs/express/llms.txt)

#### Scenario: 健康检查

**TDD 流程**：先写测试 → 实现功能
```typescript
// test/health.test.ts
test('GET /health returns 200 status', async () => {
  const response = await request(app).get('/health');
  expect(response.status).toBe(200);
  expect(response.body).toEqual({ status: 'ok' });
});
```

- **给定** BFF 服务正在运行
- **当** 客户端发送 GET 请求到 `/health`
- **那么** 返回 200 状态码和 `{ "status": "ok" }` 响应体

#### Scenario: 查询题目列表

**TDD 测试先行**：
```typescript
test('GET /questions?topic=JavaScript&difficulty=easy returns filtered questions', async () => {
  const response = await request(app)
    .get('/questions')
    .query({ topic: 'JavaScript', difficulty: 'easy', limit: 10 });

  expect(response.status).toBe(200);
  expect(Array.isArray(response.body)).toBe(true);
  expect(response.body[0]).toHaveProperty('id');
});
```

- **给定** 数据库中有题目数据
- **当** 客户端发送 GET 请求到 `/questions?topic=JavaScript&difficulty=easy&limit=10&offset=0`
- **那么** 返回 200 状态码和符合条件的题目数组

#### Scenario: 随机获取题目

**TDD 测试先行**：
```typescript
test('GET /questions/random returns different questions on each call', async () => {
  const response1 = await request(app)
    .get('/questions/random')
    .query({ topic: 'JavaScript', count: 5 });

  const response2 = await request(app)
    .get('/questions/random')
    .query({ topic: 'JavaScript', count: 5 });

  expect(response1.body).not.toEqual(response2.body);
});
```

- **给定** 数据库中有题目数据
- **当** 客户端发送 GET 请求到 `/questions/random?topic=JavaScript&count=5`
- **那么** 返回 200 状态码和随机选择的 5 道题目数组
- **并且** 每次请求返回的题目顺序应该不同

#### Scenario: 获取单题详情

- **给定** 数据库中存在 ID 为 `js-1` 的题目
- **当** 客户端发送 GET 请求到 `/questions/js-1`
- **那么** 返回 200 状态码和完整的题目数据（包含选项和正确答案）

#### Scenario: 参数验证失败

**最佳实践**：Express 错误处理中间件 - [Error Handling Middleware Pattern](https://context7.com/expressjs/express/llms.txt)

```typescript
// TDD 测试验证参数验证
test('GET /questions with invalid limit returns 400', async () => {
  const response = await request(app)
    .get('/questions')
    .query({ topic: 'JavaScript', limit: 'invalid' });

  expect(response.status).toBe(400);
  expect(response.body).toHaveProperty('error');
});
```

- **给定** BFF 服务正在运行
- **当** 客户端发送 GET 请求到 `/questions?topic=Invalid&limit=abc`
- **那么** 返回 400 状态码和错误信息

---

### Requirement: BFF MUST 使用 Clean Architecture 分层组织代码

后端代码 MUST 按照 Clean Architecture 原则分为 Routes、Controllers、Services、Repositories 四层，每层职责单一。

**最佳实践基线**：
- Express Router 模块化 - [Create Modular Route Handlers](https://context7.com/expressjs/express/llms.txt)
- Clean Architecture with Node.js & TypeScript - [Guide](https://vitalii-zdanovskyi.medium.com/a-definitive-guide-to-building-a-nodejs-app-using-clean-architecture-and-typescript-41d01c6badfa)

#### Scenario: 层级职责清晰

**TDD 验证文件结构**：
```typescript
// test/architecture/folderStructure.test.ts
import { existsSync, readdirSync } from 'fs';
import { join } from 'path';

test('project has correct Clean Architecture structure', () => {
  const srcPath = join(__dirname, '../../src');

  expect(existsSync(join(srcPath, 'routes'))).toBe(true);
  expect(existsSync(join(srcPath, 'controllers'))).toBe(true);
  expect(existsSync(join(srcPath, 'services'))).toBe(true);
  expect(existsSync(join(srcPath, 'repositories'))).toBe(true);
});
```

- **给定** BFF 项目已初始化
- **当** 查看项目目录结构
- **那么** 应包含以下目录：
  - `routes/` - 定义 API 端点
  - `controllers/` - 处理 HTTP 请求/响应
  - `services/` - 实现业务逻辑
  - `repositories/` - 访问数据库

#### Scenario: 依赖方向正确

**TDD 验证依赖注入**：
```typescript
// test/architecture/dependencies.test.ts
test('controllers only depend on services, not repositories', () => {
  const controllerFiles = glob.sync('src/controllers/**/*.ts');
  controllerFiles.forEach(file => {
    const content = readFile(file);
    expect(content).not.toMatch(/from.*\/repositories\//);
  });
});
```

- **给定** Clean Architecture 已实现
- **当** 检查代码依赖关系
- **那么** Routes → Controllers → Services → Repositories 的依赖方向是单向的
- **并且** 外层不直接调用内层的实现

---

### Requirement: BFF MUST 支持 CORS 跨域请求

BFF MUST 配置 CORS 中间件，允许 Flutter 开发环境（localhost）的跨域请求。

**最佳实践基线**：
- Express CORS 中间件配置

#### Scenario: 允许 Flutter 跨域访问

**TDD 测试 CORS 配置**：
```typescript
import request from 'supertest';

test('allows CORS requests from localhost', async () => {
  const response = await request(app)
    .get('/questions')
    .set('Origin', 'http://localhost:8080');

  expect(response.status).toBe(200);
  expect(response.headers['access-control-allow-origin']).toBeDefined();
});
```

- **给定** Flutter 应用运行在 `http://localhost:8080`
- **当** Flutter 向 BFF 发送 API 请求
- **那么** 请求应成功，不应被 CORS 策略阻止

#### Scenario: 生产环境 CORS 配置

- **给定** BFF 部署到生产环境
- **当** 配置 CORS 白名单
- **那么** 只允许指定域名访问，拒绝其他来源

---

### Requirement: BFF MUST 实现统一的错误处理

所有 API 错误 MUST 通过错误处理中间件统一处理，返回一致的错误响应格式。

**最佳实践基线**：
- Express 错误处理中间件 - [Implement Error Handling with Async Wrapper](https://context7.com/expressjs/express/llms.txt)
- Express 4-argument error middleware - [Error Handling Middleware Pattern](https://context7.com/expressjs/express/llms.txt)

#### Scenario: 404 错误处理

**TDD 测试错误处理**：
```typescript
test('returns 404 for undefined routes', async () => {
  const response = await request(app).get('/nonexistent');

  expect(response.status).toBe(404);
  expect(response.body).toMatchObject({
    error: 'Not Found',
    message: expect.any(String)
  });
});
```

- **给定** BFF 服务正在运行
- **当** 客户端请求不存在的端点 `/notfound`
- **那么** 返回 404 状态码和 `{ "error": "Not Found", "message": "资源不存在" }`

#### Scenario: 500 错误处理

**TDD 测试服务器错误**：
```typescript
test('returns 500 for unexpected errors', async () => {
  // Mock a service that throws
  jest.spyOn(questionService, 'getQuestions').mockImplementation(() => {
    throw new Error('Database connection failed');
  });

  const response = await request(app).get('/questions');

  expect(response.status).toBe(500);
  expect(response.body).toHaveProperty('error');
});
```

- **给定** BFF 服务正在运行
- **当** 服务器内部发生未捕获的异常
- **那么** 返回 500 状态码和 `{ "error": "Internal Server Error", "message": "服务器内部错误" }`
- **并且** 错误应被记录到日志

---

### Requirement: BFF MUST 记录请求日志

BFF MUST 使用 morgan 中间件记录所有 HTTP 请求，便于调试和监控。

**最佳实践基线**：
- Express 中间件使用 - [Implement Middleware Functions](https://context7.com/expressjs/express/llms.txt)

#### Scenario: 记录请求日志

**TDD 验证日志记录**：
```typescript
test('logs HTTP requests with morgan', async () => {
  const consoleSpy = jest.spyOn(console, 'log');

  await request(app).get('/health');

  expect(consoleSpy).toHaveBeenCalledWith(
    expect.stringContaining('GET /health')
  );
});
```

- **给定** BFF 服务正在运行
- **当** 客户端发送任意请求
- **那么** 控制台应输出请求日志（方法、路径、状态码、响应时间）
