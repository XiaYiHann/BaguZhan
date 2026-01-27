# M1 基础 UI 原型 - 任务清单 (TDD)

> **TDD 原则**: 红 → 绿 → 重构。每个功能先写失败的测试，再实现代码使测试通过，最后重构。

## 1. 项目初始化

- [ ] 1.1 确认 Flutter 环境 (`flutter doctor`)
- [ ] 1.2 创建 Flutter 项目 `baguzhan`
- [ ] 1.3 配置 `pubspec.yaml` 依赖 (provider, dio, shared_preferences, flutter_svg, mockito, build_runner)
- [ ] 1.4 创建项目目录结构 (core/, data/, domain/, presentation/, test/)
- [ ] 1.5 配置 `analysis_options.yaml` 代码规范
- [ ] 1.6 配置测试环境 (flutter_test, mockito, fake_async)

## 2. 数据模型 (TDD)

### 2.1 QuestionModel 测试先行
- [ ] 2.1.1 编写 `test/data/models/question_model_test.dart`
  - 测试：创建实例包含所有必需字段
  - 测试：fromJson 正确解析完整 JSON
  - 测试：fromJson 处理可选字段为 null
  - 测试：correctAnswerIndex 返回正确答案索引
  - 测试：correctAnswerIndex 无正确答案时返回 -1
- [ ] 2.1.2 实现 `QuestionModel` 类使测试通过
- [ ] 2.1.3 重构：提取常量、优化代码

### 2.2 OptionModel 测试先行
- [ ] 2.2.1 编写 `test/data/models/option_model_test.dart`
  - 测试：创建实例包含所有字段
  - 测试：fromJson 正确解析
  - 测试：optionOrder 范围验证 (0-3)
- [ ] 2.2.2 实现 `OptionModel` 类使测试通过

### 2.3 UserAnswerModel 测试先行
- [ ] 2.3.1 编写 `test/data/models/user_answer_model_test.dart`
  - 测试：记录用户答案
  - 测试：计算答题耗时
- [ ] 2.3.2 实现 `UserAnswerModel` 类使测试通过

## 3. 固定数据源 (TDD)

### 3.1 QuestionRepository 接口测试
- [ ] 3.1.1 编写 `test/data/repositories/question_repository_test.dart`
  - 测试：getQuestions 返回题目列表
  - 测试：getQuestions 按主题筛选
  - 测试：getQuestions 限制数量
  - 测试：getQuestionById 返回单个题目
  - 测试：getQuestionById 不存在时返回 null
- [ ] 3.1.2 定义 `QuestionRepository` 抽象接口
- [ ] 3.1.3 实现 `LocalQuestionRepository` 使测试通过

### 3.2 固定题库数据
- [ ] 3.2.1 编写测试验证题库数据完整性
  - 测试：至少包含 8 道题
  - 测试：JavaScript 主题至少 5 道
  - 测试：每道题有 4 个选项
  - 测试：每道题有且仅有 1 个正确答案
  - 测试：每道题包含解析
- [ ] 3.2.2 创建 `LocalQuestionDatasource` 并填充题目数据

## 4. 状态管理 (TDD)

### 4.1 QuestionProvider 核心逻辑测试
- [ ] 4.1.1 编写 `test/presentation/providers/question_provider_test.dart`
  - 测试：初始状态 - isLoading=false, questions=[], currentIndex=0
  - 测试：loadQuestions - 加载中状态变化
  - 测试：loadQuestions - 成功后 questions 填充
  - 测试：loadQuestions - 失败时设置错误状态
  - 测试：selectOption - 记录选择
  - 测试：selectOption - 重复选择覆盖之前选择
  - 测试：submitAnswer - 正确答案返回 isCorrect=true
  - 测试：submitAnswer - 错误答案返回 isCorrect=false
  - 测试：submitAnswer - 更新正确/错误计数
  - 测试：nextQuestion - 索引递增
  - 测试：nextQuestion - 最后一题标记完成
  - 测试：reset - 重置所有状态
  - 测试：统计数据 - 正确率计算
- [ ] 4.1.2 创建 Mock Repository (`MockQuestionRepository`)
- [ ] 4.1.3 实现 `QuestionProvider` 使所有测试通过
- [ ] 4.1.4 重构：提取状态枚举、优化通知逻辑

## 5. 主题与样式

- [ ] 5.1 创建 `AppTheme` 类
- [ ] 5.2 定义配色方案常量
- [ ] 5.3 定义字体样式
- [ ] 5.4 编写主题一致性测试（可选）

## 6. UI 组件 (TDD)

### 6.1 OptionCard 组件测试先行
- [ ] 6.1.1 编写 `test/presentation/widgets/option_card_test.dart`
  - 测试：渲染选项文本
  - 测试：渲染选项字母 (A/B/C/D)
  - 测试：默认状态 - 灰色边框
  - 测试：选中状态 - 蓝色边框
  - 测试：正确状态 - 绿色边框+背景
  - 测试：错误状态 - 红色边框+背景
  - 测试：点击触发 onTap 回调
  - 测试：已提交后点击无响应
- [ ] 6.1.2 实现 `OptionCard` 组件使测试通过

### 6.2 QuestionCard 组件测试先行
- [ ] 6.2.1 编写 `test/presentation/widgets/question_card_test.dart`
  - 测试：渲染题目内容
  - 测试：渲染难度标签
  - 测试：渲染标签列表
  - 测试：长文本可滚动
- [ ] 6.2.2 实现 `QuestionCard` 组件使测试通过

### 6.3 ProgressBar 组件测试先行
- [ ] 6.3.1 编写 `test/presentation/widgets/progress_bar_test.dart`
  - 测试：显示 "第 X 题 / 共 Y 题"
  - 测试：进度条宽度比例正确
  - 测试：边界情况 - 第 1 题
  - 测试：边界情况 - 最后 1 题
- [ ] 6.3.2 实现 `ProgressBar` 组件使测试通过

### 6.4 FeedbackPanel 组件测试先行
- [ ] 6.4.1 编写 `test/presentation/widgets/feedback_panel_test.dart`
  - 测试：正确时显示绿色背景
  - 测试：错误时显示红色背景
  - 测试：显示解析内容
  - 测试：显示助记口诀（如有）
  - 测试：显示实战场景（如有）
  - 测试：点击继续按钮触发回调
- [ ] 6.4.2 实现 `FeedbackPanel` 组件使测试通过

## 7. 页面 (TDD)

### 7.1 HomePage 测试先行
- [ ] 7.1.1 编写 `test/presentation/pages/home_page_test.dart`
  - 测试：显示应用标题
  - 测试：显示主题列表
  - 测试：点击主题导航到答题页
- [ ] 7.1.2 实现 `HomePage` 使测试通过

### 7.2 QuestionPage 测试先行
- [ ] 7.2.1 编写 `test/presentation/pages/question_page_test.dart`
  - 测试：加载中显示 loading 指示器
  - 测试：加载完成显示题目
  - 测试：显示 4 个选项
  - 测试：选择选项后高亮
  - 测试：未选择时提交按钮禁用
  - 测试：提交后显示反馈面板
  - 测试：点击下一题切换题目
  - 测试：最后一题完成后导航到结果页
- [ ] 7.2.2 实现 `QuestionPage` 使测试通过

### 7.3 ResultPage 测试先行
- [ ] 7.3.1 编写 `test/presentation/pages/result_page_test.dart`
  - 测试：显示总题数
  - 测试：显示正确数和错误数
  - 测试：显示正确率
  - 测试：点击重新开始导航到答题页
  - 测试：点击返回首页导航到首页
- [ ] 7.3.2 实现 `ResultPage` 使测试通过

## 8. 集成测试

- [ ] 8.1 编写 `integration_test/complete_flow_test.dart`
  - 测试：完整答题流程 - 首页 → 选主题 → 答题 → 结果
  - 测试：全部答对场景
  - 测试：全部答错场景
  - 测试：中途返回首页
- [ ] 8.2 编写 `integration_test/navigation_test.dart`
  - 测试：页面间导航正确
  - 测试：返回按钮行为
- [ ] 8.3 运行所有测试并确保通过

## 9. 路由配置

- [ ] 9.1 配置 Navigator 路由
- [ ] 9.2 实现页面间参数传递
- [ ] 9.3 测试路由逻辑

## 10. 最终验收

- [ ] 10.1 运行 `flutter test` 确保所有单元测试通过
- [ ] 10.2 运行 `flutter test integration_test` 确保集成测试通过
- [ ] 10.3 运行 `flutter analyze` 确保无 lint 错误
- [ ] 10.4 手动验收所有功能点
