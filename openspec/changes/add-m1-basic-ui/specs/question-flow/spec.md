## ADDED Requirements

### Requirement: 题目数据模型

系统 MUST 定义完整的题目数据模型，与后端 API 结构一致。

#### Scenario: QuestionModel 包含完整字段

- **当** 创建 QuestionModel 实例
- **那么** 包含以下字段：
  - id (String) - 唯一标识
  - content (String) - 题目内容
  - topic (String) - 主题分类
  - difficulty (String) - 难度等级 (easy/medium/hard)
  - explanation (String?) - 详细解析
  - mnemonic (String?) - 助记口诀
  - scenario (String?) - 实战场景
  - tags (List<String>) - 标签列表
  - options (List<OptionModel>) - 选项列表

#### Scenario: OptionModel 包含完整字段

- **当** 创建 OptionModel 实例
- **那么** 包含以下字段：
  - id (String) - 唯一标识
  - optionText (String) - 选项内容
  - optionOrder (int) - 选项顺序 (0-3)
  - isCorrect (bool) - 是否正确答案

#### Scenario: 支持 JSON 反序列化

- **当** 从 JSON 数据创建模型
- **那么** `fromJson()` 工厂方法正确解析所有字段

### Requirement: 固定题库数据源

系统 MUST 提供至少 8 道预置题目，覆盖多个主题。

#### Scenario: JavaScript 主题题目

- **当** 请求 JavaScript 主题题目
- **那么** 返回至少 5 道 JavaScript 基础题
- **并且** 每道题包含解析、助记和场景

#### Scenario: React/Vue 主题题目

- **当** 请求 React 或 Vue 主题题目
- **那么** 返回至少 3 道相关题目

### Requirement: 题库仓储抽象

系统 MUST 通过 Repository 模式抽象数据访问，支持后续替换数据源。

#### Scenario: 本地数据源实现

- **当** M1 阶段运行应用
- **那么** 使用 LocalQuestionRepository 返回固定数据

#### Scenario: 支持按主题筛选

- **当** 调用 `getQuestions(topic: 'JavaScript')`
- **那么** 仅返回 JavaScript 主题的题目

### Requirement: 答题状态管理

系统 MUST 通过 QuestionProvider 管理答题流程状态。

#### Scenario: 加载题目

- **当** 调用 `loadQuestions(topic)`
- **那么** 状态从 loading 变为 ready
- **并且** 题目列表被填充

#### Scenario: 选择选项

- **当** 用户点击选项
- **那么** 调用 `selectOption(questionId, optionIndex)`
- **并且** 记录用户选择

#### Scenario: 提交答案

- **当** 调用 `submitAnswer()`
- **那么** 判断答案正确性
- **并且** 状态变为 answered
- **并且** 更新统计数据（正确数/错误数）

#### Scenario: 下一题

- **当** 调用 `nextQuestion()`
- **那么** currentQuestionIndex 增加
- **或者** 如果是最后一题，标记答题完成

### Requirement: 答题结果统计

系统 MUST 记录并统计本轮答题结果。

#### Scenario: 统计正确率

- **当** 完成一轮答题
- **那么** 可获取总题数、正确数、错误数、正确率

#### Scenario: 记录每题结果

- **当** 每次提交答案后
- **那么** 记录该题的用户选择、是否正确、答题时间
