# testing Specification

## Purpose
TBD - created by archiving change add-m1-basic-ui. Update Purpose after archive.
## 需求
### Requirement: 测试基础设施

系统 MUST 配置完整的测试基础设施，支持 TDD 开发流程。

#### Scenario: 测试依赖配置

- **当** 查看 `pubspec.yaml` 的 dev_dependencies
- **那么** 包含以下测试依赖：
  - flutter_test（Flutter 测试框架）
  - mockito（Mock 对象）
  - build_runner（代码生成）
  - fake_async（异步测试）

#### Scenario: 测试目录结构

- **当** 查看项目 test 目录
- **那么** 结构镜像 lib 目录：
  - `test/data/models/` - 数据模型测试
  - `test/data/repositories/` - 仓储测试
  - `test/presentation/providers/` - 状态管理测试
  - `test/presentation/widgets/` - 组件测试
  - `test/presentation/pages/` - 页面测试

#### Scenario: 运行测试命令

- **当** 执行 `flutter test`
- **那么** 所有单元测试和组件测试执行
- **并且** 输出测试结果和覆盖率

### Requirement: 数据模型单元测试

系统 MUST 为所有数据模型提供完整的单元测试覆盖。

#### Scenario: QuestionModel 测试覆盖

- **当** 运行 QuestionModel 测试
- **那么** 验证以下场景：
  - 创建实例包含所有必需字段
  - fromJson 正确解析完整 JSON
  - fromJson 处理可选字段为 null
  - correctAnswerIndex 返回正确答案索引
  - correctAnswerIndex 无正确答案时返回 -1

#### Scenario: OptionModel 测试覆盖

- **当** 运行 OptionModel 测试
- **那么** 验证以下场景：
  - 创建实例包含所有字段
  - fromJson 正确解析
  - optionOrder 范围验证

### Requirement: 仓储层测试

系统 MUST 为数据仓储提供可 Mock 的接口和测试。

#### Scenario: Repository 接口可 Mock

- **当** 编写依赖 Repository 的测试
- **那么** 可使用 MockQuestionRepository 替代真实实现

#### Scenario: LocalQuestionRepository 测试

- **当** 运行 Repository 测试
- **那么** 验证以下场景：
  - getQuestions 返回题目列表
  - getQuestions 按主题筛选正确
  - getQuestions 限制数量生效
  - getQuestionById 返回正确题目
  - getQuestionById 不存在时返回 null

### Requirement: 状态管理测试

系统 MUST 为 QuestionProvider 提供全面的单元测试。

#### Scenario: 状态变化测试

- **当** 运行 QuestionProvider 测试
- **那么** 验证以下状态变化：
  - 初始状态正确
  - loadQuestions 触发加载状态
  - loadQuestions 成功后填充数据
  - selectOption 记录用户选择
  - submitAnswer 判断正确性
  - nextQuestion 更新索引
  - reset 重置所有状态

#### Scenario: 统计计算测试

- **当** 完成多道题目后
- **那么** 正确计算：
  - 总题数
  - 正确数
  - 错误数
  - 正确率（百分比）

### Requirement: 组件测试

系统 MUST 为所有核心 UI 组件提供 Widget 测试。

#### Scenario: OptionCard 状态测试

- **当** 运行 OptionCard 测试
- **那么** 验证以下状态渲染：
  - 默认状态显示灰色边框
  - 选中状态显示蓝色边框
  - 正确状态显示绿色边框和背景
  - 错误状态显示红色边框和背景

#### Scenario: OptionCard 交互测试

- **当** 运行 OptionCard 交互测试
- **那么** 验证：
  - 点击触发 onTap 回调
  - 已提交后点击无响应

#### Scenario: FeedbackPanel 测试

- **当** 运行 FeedbackPanel 测试
- **那么** 验证：
  - 正确时显示绿色主题
  - 错误时显示红色主题
  - 解析内容正确渲染
  - 助记口诀正确渲染（如有）

### Requirement: 页面集成测试

系统 MUST 为核心页面提供集成测试。

#### Scenario: QuestionPage 流程测试

- **当** 运行 QuestionPage 测试
- **那么** 验证完整交互流程：
  - 加载中显示 loading
  - 加载完成显示题目和选项
  - 选择选项后高亮
  - 提交后显示反馈
  - 下一题切换正常

#### Scenario: ResultPage 显示测试

- **当** 运行 ResultPage 测试
- **那么** 验证：
  - 统计数据正确显示
  - 导航按钮功能正常

### Requirement: 端到端集成测试

系统 MUST 提供完整用户流程的集成测试。

#### Scenario: 完整答题流程

- **当** 运行完整流程测试
- **那么** 验证从首页到结果页的完整路径：
  - 首页选择主题
  - 加载题目
  - 完成所有题目
  - 显示结果统计
  - 可重新开始或返回首页

#### Scenario: 边界场景测试

- **当** 运行边界场景测试
- **那么** 验证：
  - 全部答对场景
  - 全部答错场景
  - 只有一道题场景

### Requirement: 本地测试环境

系统 MUST 支持使用 Xcode 进行本地 iOS 模拟器测试。

#### Scenario: Xcode 环境配置

- **当** 开发者需要运行本地测试
- **那么** 使用 Xcode 打开 `ios/Runner.xcworkspace`
- **并且** 可选择 iOS 模拟器作为测试目标

#### Scenario: 模拟器测试运行

- **当** 在 Xcode 中执行测试 (Cmd+U)
- **那么** 所有单元测试和 Widget 测试在模拟器中运行
- **并且** 测试结果在 Xcode Test Navigator 中展示

#### Scenario: 集成测试运行

- **当** 需要运行集成测试
- **那么** 执行 `flutter test integration_test` 在 iOS 模拟器上运行
- **或者** 在 Xcode 中配置 UI Test Target 运行

#### Scenario: 调试支持

- **当** 测试失败需要调试
- **那么** 可在 Xcode 中设置断点
- **并且** 使用 LLDB 调试器进行问题定位

### Requirement: 测试覆盖率要求

系统 MUST 达到规定的测试覆盖率标准。

#### Scenario: 核心逻辑覆盖率

- **当** 运行覆盖率检查
- **那么** 以下模块覆盖率 >= 80%：
  - data/models/
  - data/repositories/
  - presentation/providers/

#### Scenario: UI 组件覆盖率

- **当** 运行覆盖率检查
- **那么** 以下模块覆盖率 >= 60%：
  - presentation/widgets/
  - presentation/pages/

### 需求：UI 回归测试

系统 MUST 为关键视觉状态提供可自动化回归测试，避免 UI 退化。

#### 场景：关键组件 Golden 覆盖

- **当** UI 视觉调整或依赖升级
- **那么** OptionCard、ProgressBar、FeedbackPanel 的关键状态有 Golden 测试覆盖

