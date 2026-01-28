# 变更：M2 接入 BFF + PostgreSQL 题库

## 为什么

M1 阶段已完成基础 UI 原型，使用固定数据源验证了答题流程。现在需要接入真实后端，实现从数据库读取题库，支持按主题/难度筛选、随机出题等功能，为后续多用户和内容管理打下基础。

## 变更内容

### 后端部分（Node.js + TypeScript + Express）
- 初始化 Node.js/TypeScript BFF 项目
- 使用 **Clean Architecture** 分层：Routes → Controllers → Services → Repositories
- 配置 **SQLite** 本地数据库（开发环境，后续可切换 PostgreSQL）
- 实现 RESTful API：`GET /questions`, `GET /questions/random`, `GET /questions/:id`
- 配置 **CORS** 支持跨域请求
- 添加 **请求日志** 和 **错误处理中间件**
- 编写 API 集成测试

### 前端部分（Flutter）
- 添加 **Dio** HTTP 客户端配置（替代固定数据源）
- 创建 **ApiQuestionRepository** 实现远程题目获取
- 修改 **QuestionProvider** 支持加载状态和错误处理
- 添加 **网络异常** 和 **超时重试** 处理
- 更新集成测试支持 Mock API 响应

### 数据库设计
- **questions 表**：id, content, topic, difficulty, explanation, mnemonic, scenario, tags
- **options 表**：id, question_id, option_text, option_order, is_correct
- 添加索引：topic, difficulty, (topic, difficulty) 复合索引
- 实现随机查询：`ORDER BY RANDOM() LIMIT ?`
- 预置种子数据（复用 M1 的 8 道题）

## 影响

- 受影响规范：
  - `bff` (新增) - BFF 后端架构与 API 设计
  - `database` (新增) - 数据库 Schema 与查询优化
  - `api-client` (新增) - Flutter API 客户端与错误处理
- 受影响代码：
  - 新增 `server/` 目录（Node.js BFF）
  - 修改 `baguzhan/lib/data/repositories/`（添加 API repository）
  - 修改 `baguzhan/lib/presentation/providers/`（支持网络状态）

## 技术选型（基于最佳实践）

### 后端架构
参考 [Clean Architecture with Node.js & TypeScript](https://vitalii-zdanovskyi.medium.com/a-definitive-guide-to-building-a-nodejs-app-using-clean-architecture-and-typescript-41d01c6badfa) 和 [2025 Node.js Folder Structure](https://dev.to/pramod_boda/recommended-folder-structure-for-nodets-2025-39jl)：

```
server/
├── src/
│   ├── routes/         # 路由定义
│   ├── controllers/    # 请求处理
│   ├── services/       # 业务逻辑
│   ├── repositories/   # 数据访问
│   ├── middlewares/    # 中间件
│   ├── config/         # 配置
│   └── database/       # 数据库连接
```

### Flutter API 集成
参考 [Flutter REST API with Provider](https://medium.com/@info_80576/flutter-rest-api-integration-a-complete-guide-1002a5bff7f3)：
- **Dio** 替代 `http` 包（支持拦截器、超时、重试）
- **Provider** 管理加载状态
- **分离 Repository** 抽象（方便 Mock 测试）

### 数据库优化
参考 [PostgreSQL Best Practices 2025](https://www.instaclustr.com/education/postgresql/top-10-postgresql-best-practices-for-2025/) 和 [PostgreSQL 随机抽题](https://blog.csdn.net/luansj/article/details/118939166)：
- 使用索引优化筛选查询
- `ORDER BY RANDOM()` 实现随机出题
- 数据迁移脚本管理版本

## 验收标准

- [x] BFF 服务可启动，响应 `/health` 端点
- [x] `GET /questions?topic=JavaScript&difficulty=easy` 返回筛选结果
- [x] `GET /questions/random?topic=JavaScript&count=5` 返回随机题目
- [x] Flutter 可从 API 加载题目并显示
- [x] 网络错误时显示友好提示
- [x] 所有 API 集成测试通过
- [x] Flutter 集成测试使用 Mock API 通过

## 参考资源

### 技术栈最佳实践

**后端架构**
- [Clean Architecture with Node.js & TypeScript](https://vitalii-zdanovskyi.medium.com/a-definitive-guide-to-building-a-nodejs-app-using-clean-architecture-and-typescript-41d01c6badfa)
- [Recommended Folder Structure for Node(TS) 2025](https://dev.to/pramod_boda/recommended-folder-structure-for-nodets-2025-39jl)
- [Flutter App Architecture Recommendations (Official Docs)](https://docs.flutter.dev/app-architecture/recommendations)

**Flutter API 集成**
- [Flutter REST API Integration: A Complete Guide](https://medium.com/@info_80576/flutter-rest-api-integration-a-complete-guide-1002a5bff7f3)
- [Effective Network Handling in Flutter: REST API Integration](https://dev.to/nkusikevin/how-to-build-a-robust-design-system-in-flutter-with-theming-and-material-3-support-1g4o)
- [State Management in Flutter: Best Practices for 2025](https://vibe-studio.ai/insights/state-management-in-flutter-best-practices-for-2025)

**数据库设计**
- [Top 10 PostgreSQL best practices for 2025](https://www.instaclustr.com/education/postgresql/top-10-postgresql-best-practices-for-2025/)
- [Best Practices for SQL & PostgreSQL in 2025](https://medium.com/learning-data/best-practices-for-sql-postgresql-in-2025-keep-your-database-from-crying-317eaf06f688)
- [PostgreSQL 随机抽题](https://blog.csdn.net/luansj/article/details/118939166)
