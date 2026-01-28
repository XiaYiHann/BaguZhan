# 更新日志

## [0.2.0] - 2025-01-28

### 新增

#### 后端 (BFF)
- 初始化 Node.js + TypeScript BFF 项目
- 实现 Clean Architecture 分层架构
- 配置 SQLite 数据库（开发环境）
- 实现 RESTful API 端点：
  - `GET /health` - 健康检查
  - `GET /questions` - 获取题目列表（支持筛选、分页）
  - `GET /questions/random` - 随机获取题目
  - `GET /questions/:id` - 获取单个题目
- 添加 CORS 支持跨域请求
- 添加请求日志和错误处理中间件
- 编写 API 集成测试（覆盖率 > 80%）

#### 前端 (Flutter)
- 添加 Dio HTTP 客户端配置
- 创建 `ApiQuestionRepository` 实现远程题目获取
- 修改 `QuestionProvider` 支持加载状态和错误处理
- 添加网络异常和超时重试处理
- 更新集成测试支持 Mock API 响应

#### 数据库
- 设计 `questions` 和 `options` 表结构
- 添加索引优化查询性能
- 实现随机查询 `ORDER BY RANDOM() LIMIT ?`
- 预置种子数据（8 道题目）

### 技术选型

- **后端**: Node.js, TypeScript, Express, SQLite
- **前端**: Flutter, Dio, Provider
- **架构**: Clean Architecture, REST API

## [0.1.0] - 2025-01-26

### 新增

- 基础 UI 原型
- 答题流程实现
- 主题选择页面
- 答题结果统计
- 本地数据源（Mock 数据）
