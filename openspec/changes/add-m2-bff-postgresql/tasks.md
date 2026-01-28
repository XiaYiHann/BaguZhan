# M2 任务清单

## 阶段 1：后端基础设施

### 1.1 初始化 BFF 项目
- [x] 创建 `server/` 目录
- [x] 初始化 `package.json`（TypeScript + Express）
- [x] 配置 `tsconfig.json`
- [x] 添加依赖：express, cors, morgan, sqlite3
- [x] 配置 ESLint + Prettier
- **验证**：`npm run dev` 可启动空服务

### 1.2 数据库初始化
- [x] 创建 `database/` 目录
- [x] 编写 Schema SQL（questions + options 表）
- [x] 创建索引（topic, difficulty, 复合索引）
- [x] 编写种子数据 SQL（8 道题）
- [x] 实现数据库连接模块
- **验证**：可执行 `npm run db:migrate` 和 `npm run db:seed`

### 1.3 实现数据访问层（Repositories）
- [x] 创建 `repositories/QuestionRepository.ts`
- [x] 实现 `getAll(filters)` 方法
- [x] 实现 `getRandom(filters)` 方法
- [x] 实现 `getById(id)` 方法
- [x] 添加单元测试
- **验证**：所有测试通过，可直接查询数据库

### 1.4 实现业务逻辑层（Services）
- [x] 创建 `services/QuestionService.ts`
- [x] 实现 `queryQuestions(filters)` 业务逻辑
- [x] 实现 `getRandomQuestions(filters)` 业务逻辑
- [x] 添加参数验证
- [x] 添加单元测试
- **验证**：所有测试通过

## 阶段 2：API 实现

### 2.1 实现路由和控制器
- [x] 创建 `routes/questions.ts`
- [x] 创建 `controllers/QuestionController.ts`
- [x] 实现 `GET /health` 端点
- [x] 实现 `GET /questions` 端点
- [x] 实现 `GET /questions/random` 端点
- [x] 实现 `GET /questions/:id` 端点
- **验证**：使用 curl/Postman 测试所有端点

### 2.2 添加中间件
- [x] 配置 CORS 中间件
- [x] 添加请求日志（morgan）
- [x] 实现错误处理中间件
- [x] 添加参数验证中间件
- **验证**：错误请求返回正确状态码

### 2.3 API 集成测试
- [x] 配置 Jest/Vitest 测试环境
- [x] 编写端到端测试套件
- [x] 测试筛选查询逻辑
- [x] 测试随机查询逻辑
- [x] 测试错误处理
- **验证**：所有测试通过，覆盖率 > 80%

## 阶段 3：Flutter API 集成

### 3.1 添加 Dio 配置
- [x] 在 `pubspec.yaml` 添加 dio 依赖
- [x] 创建 `lib/network/api_client.dart`
- [x] 配置基础 URL、超时、拦截器
- [x] 添加日志拦截器
- [x] 添加错误处理拦截器
- **验证**：可发起基本 HTTP 请求

### 3.2 实现 API Repository
- [x] 创建 `lib/data/repositories/api_question_repository.dart`
- [x] 实现 `QuestionRepository` 接口
- [x] 实现 `getQuestions()` 方法
- [x] 实现 `getRandomQuestions()` 方法
- [x] 实现 `getQuestionById()` 方法
- [x] 添加单元测试（Mock Dio）
- **验证**：所有测试通过

### 3.3 修改 Provider 支持网络状态
- [x] 更新 `QuestionProvider` 添加状态枚举
- [x] 实现 `loadQuestions()` 异步方法
- [x] 添加错误处理逻辑
- [x] 添加加载状态显示
- [x] 更新 UI 显示错误提示
- **验证**：可正常加载题目，错误时有提示

### 3.4 替换数据源
- [x] 修改 `main.dart` 注入 `ApiQuestionRepository`
- [x] 移除或保留 `LocalQuestionRepository`（用于测试）
- [x] 更新集成测试使用 Mock API
- **验证**：应用可从 API 加载数据

## 阶段 4：测试与优化

### 4.1 端到端测试
- [x] 编写 Flutter 集成测试（Mock Server）
- [x] 测试完整答题流程
- [x] 测试网络错误场景
- [x] 测试超时场景
- **验证**：所有 E2E 测试通过

### 4.2 性能验证
- [x] 测试 API 响应时间（目标 < 100ms）
- [x] 测试随机查询性能
- [x] 验证数据库索引生效
- **验证**：性能指标达标

### 4.3 文档完善
- [x] 编写 API README（端点说明）
- [x] 添加 Postman Collection
- [x] 更新项目 README（M2 说明）
- **验证**：新开发者可按文档启动服务

## 阶段 5：清理与发布

### 5.1 代码审查准备
- [x] 运行 ESLint 检查
- [x] 运行 Flutter analyze
- [x] 确保所有测试通过
- [x] 移除调试代码和 console.log
- **验证**：代码质量检查通过

### 5.2 合并准备
- [x] 更新 CHANGELOG
- [ ] 合并分支到 main
- [ ] 创建 GitHub Release
- **验证**：版本发布成功

## 依赖关系

```
1.1 → 1.2 → 1.3 → 1.4
                 ↓
            2.1 → 2.2 → 2.3
                      ↓
                  3.1 → 3.2 → 3.3 → 3.4
                                    ↓
                              4.1 → 4.2 → 4.3
                                          ↓
                                    5.1 → 5.2
```

## 可并行任务

- **阶段 1** 和 **阶段 3 的前半部分** 可部分并行（如配置 Flutter Dio）
- **阶段 2** 和 **阶段 3** 可并行开发（前后端分离）
- **测试编写** 可与功能开发并行进行
