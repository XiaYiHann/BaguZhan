# M1 基础 UI 原型 - 技术设计

## 上下文

这是八股斩项目的首个实现里程碑。目标是快速搭建可运行的 Flutter 原型，验证核心答题体验。本阶段使用固定数据，不涉及后端对接。

**约束**：
- 移动端优先
- 多邻国风格设计系统
- TDD 开发方式
- 代码结构需支持后续 M2 阶段的 API 对接

## 目标 / 非目标

**目标**：
- 建立清晰的分层架构
- 实现完整答题循环
- 验证核心交互体验
- 建立测试基础设施

**非目标**：
- 后端 API 对接 (M2)
- 视觉动效优化 (M3)
- 数据持久化 (M4)
- 用户认证

## 决策

### 决策 1：状态管理选择 Provider

**选择**：使用 `provider` 包进行状态管理

**考虑的替代方案**：
- Riverpod - 更强大但学习曲线较陡，MVP 阶段过于复杂
- Bloc - 样板代码多，对于当前规模过于重量级
- GetX - 争议较大，社区不推荐

**理由**：
- 官方推荐，文档完善
- 轻量级，易于理解
- 后续可平滑迁移到 Riverpod

### 决策 2：项目结构采用分层架构

```
lib/
├── core/           # 常量、主题、工具类
├── data/           # 数据层：模型、仓储实现、数据源
├── domain/         # 领域层：实体、用例（可选，M1 简化）
├── presentation/   # 表现层：页面、组件、状态管理
└── main.dart
```

**理由**：
- 清晰的职责分离
- 便于测试
- 支持后续替换数据源（本地 → API）

### 决策 3：数据源抽象

使用 Repository 模式抽象数据访问：

```dart
abstract class QuestionRepository {
  Future<List<QuestionModel>> getQuestions({String? topic, int limit = 10});
}

class LocalQuestionRepository implements QuestionRepository {
  // M1: 返回固定数据
}

class ApiQuestionRepository implements QuestionRepository {
  // M2: 调用 BFF API
}
```

**理由**：
- M2 阶段只需实现新的 Repository，不改动 UI 层
- 便于单元测试（Mock Repository）

### 决策 4：固定数据结构

题目数据结构与后端 API 保持一致：

```dart
class QuestionModel {
  final String id;
  final String content;
  final String topic;
  final String difficulty;  // easy, medium, hard
  final String? explanation;
  final String? mnemonic;
  final String? scenario;
  final List<String> tags;
  final List<OptionModel> options;
}
```

**理由**：
- 与数据库设计一致
- M2 对接时无需修改模型

## 风险 / 权衡

| 风险 | 缓解措施 |
|------|----------|
| 固定数据量少，无法验证滚动性能 | M1 至少准备 8 道题，M2 对接后再优化 |
| Provider 后续迁移成本 | 保持 Provider 使用简单，不过度耦合 |
| 多邻国风格理解偏差 | 参考 ref/ 目录的 HTML 原型 |

## 技术要点

### 状态流转

```
HomePage
    ↓ 选择主题
QuestionPage (状态：loading → ready → answered → feedback)
    ↓ 完成所有题目
ResultPage
    ↓ 重新开始 / 返回首页
HomePage / QuestionPage
```

### TDD 开发流程

本项目采用 **测试驱动开发 (TDD)**，遵循 **红 → 绿 → 重构** 循环：

```
1. 红：编写一个失败的测试
2. 绿：编写最少代码使测试通过
3. 重构：优化代码，保持测试通过
```

**开发顺序**：
```
数据模型测试 → 数据模型实现
    ↓
仓储测试 → 仓储实现
    ↓
Provider测试 → Provider实现
    ↓
组件测试 → 组件实现
    ↓
页面测试 → 页面实现
    ↓
集成测试 → 路由配置
```

### 测试策略

#### 测试金字塔

```
        /\
       /  \  集成测试 (10%)
      /----\  - 完整答题流程
     /      \  - 导航测试
    /--------\  组件测试 (30%)
   /          \  - OptionCard 状态
  /            \  - QuestionCard 渲染
 /--------------\  - FeedbackPanel 内容
/                \  单元测试 (60%)
------------------  - 数据模型
                    - Repository
                    - Provider 状态机
```

#### 测试分类

| 类型 | 目标 | 工具 | 覆盖率要求 |
|------|------|------|-----------|
| 单元测试 | 数据模型、业务逻辑 | flutter_test, mockito | ≥ 80% |
| 组件测试 | UI 组件渲染和交互 | flutter_test | ≥ 60% |
| 集成测试 | 完整用户流程 | integration_test | 核心流程 100% |

#### Mock 策略

```dart
// 使用 Mockito 生成 Mock 类
@GenerateMocks([QuestionRepository])
void main() {
  late MockQuestionRepository mockRepository;
  late QuestionProvider provider;

  setUp(() {
    mockRepository = MockQuestionRepository();
    provider = QuestionProvider(mockRepository);
  });

  test('加载题目成功', () async {
    when(mockRepository.getQuestions(topic: 'JavaScript'))
        .thenAnswer((_) async => mockQuestions);
    
    await provider.loadQuestions('JavaScript');
    
    expect(provider.questions, equals(mockQuestions));
    expect(provider.isLoading, false);
  });
}
```

#### 测试文件命名

```
test/
├── data/
│   ├── models/
│   │   ├── question_model_test.dart
│   │   └── option_model_test.dart
│   └── repositories/
│       └── question_repository_test.dart
├── presentation/
│   ├── providers/
│   │   └── question_provider_test.dart
│   ├── widgets/
│   │   ├── option_card_test.dart
│   │   ├── question_card_test.dart
│   │   ├── progress_bar_test.dart
│   │   └── feedback_panel_test.dart
│   └── pages/
│       ├── home_page_test.dart
│       ├── question_page_test.dart
│       └── result_page_test.dart
└── integration_test/
    ├── complete_flow_test.dart
    └── navigation_test.dart
```

#### CI 测试命令

```bash
# 运行所有单元/组件测试
flutter test

# 运行并生成覆盖率
flutter test --coverage

# 运行集成测试
flutter test integration_test

# 查看覆盖率报告
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 待决问题

- [ ] 是否需要支持深色模式？（建议 M3 再考虑）
- [ ] 题目是否支持代码高亮？（建议 M2/M3 再实现）
