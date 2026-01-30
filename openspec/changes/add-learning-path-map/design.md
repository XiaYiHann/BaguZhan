# 设计文档：学习路径地图系统

## 上下文

八股斩当前点击技术栈后直接进入答题页面，缺乏结构化的学习引导。用户希望：
1. 看到技术栈内的知识点分类和进阶路线
2. 以游戏化闯关的形式学习
3. 直观了解自己的学习进度

## 目标 / 非目标

### 目标
- 提供可视化的学习路径地图（垂直闯关形式）
- 支持技术栈 → 分类 → 路径节点 → 答题的层级结构
- 游戏化体验：角色引导、解锁机制、进度追踪
- 保持Neo-Brutal视觉风格一致性

### 非目标
- 不改变现有题目数据结构和答题逻辑
- 不强制用户按顺序学习（已解锁节点可自由选择）
- 不增加社交/排行榜功能（后续迭代考虑）

## 页面映射

```
HomePage
    ↓ (点击技术栈)
PathCategoryPage (技术栈分类列表)
    ↓ (点击分类)
LearningPathMapPage (垂直路径地图)
    ↓ (点击节点)
QuestionPage (从节点加载题目)
    ↓ (完成答题)
NodeDetailPage / CelebrationPage
```

## 数据模型设计

### LearningPathModel
```dart
class LearningPathModel {
  final String id;
  final String techStack;          // 技术栈名称：JavaScript
  final String title;              // 显示标题：JavaScript核心
  final String subtitle;           // 副标题：从基础到进阶
  final String characterIcon;      // 角色图标：🗡️
  final String characterDialog;    // 角色对话框文本
  final List<PathCategoryModel> categories;
  final int totalNodes;
  final int completedNodes;
}
```

### PathCategoryModel
```dart
class PathCategoryModel {
  final String id;
  final String name;               // 分类名称：基础语法
  final String icon;               // 图标：📘
  final String color;              // 主题色：#58CC02
  final int order;                 // 排序：1
  final int totalNodes;
  final int completedNodes;
  final List<PathNodeModel> nodes;
}
```

### PathNodeModel
```dart
class PathNodeModel {
  final String id;
  final String title;              // 节点标题：变量与作用域
  final String icon;               // 图标：☕
  final String color;              // 节点颜色：primary/secondary/accent
  final int order;                 // 在路径中的顺序
  final NodeStatus status;         // 状态：locked/unlocked/completed
  final List<String> questionIds;  // 关联题目ID列表
  final String? prerequisiteNodeId;// 前置节点ID
  final int estimatedMinutes;      // 预计完成时间
}

enum NodeStatus { locked, unlocked, completed }
```

## 页面设计

### PathCategoryPage

```
┌─────────────────────────────────────┐
│  🔥15  ✅92%  📚450  💎1.2k         │  ← NeoStatBar
├─────────────────────────────────────┤
│  ← JavaScript                       │  ← 返回按钮
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │  📘 基础语法                 │    │  ← PathCategoryCard
│  │  5个关卡 • 进度 3/5          │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │  ⚡ 进阶概念                 │    │
│  │  8个关卡 • 进度 0/8 (锁定)   │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │  🚀 ES6+特性                │    │
│  │  6个关卡 • 进度 0/6 (锁定)   │    │
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│  🏠  📚  🏆  💪  👤                 │  ← NeoBottomNav
└─────────────────────────────────────┘
```

### LearningPathMapPage

参考用户HTML原型：

```
┌─────────────────────────────────────┐
│  🔥15  ✅92%  📚450  💎1.2k         │  ← NeoStatBar
├─────────────────────────────────────┤
│  ← 基础语法                          │  ← 返回 + 标题
├─────────────────────────────────────┤
│                                     │
│     ┌─────────┐                     │  ← 角色对话框
│     │READY TO │                     │
│     │SLASH... │                     │
│     └────┬────┘                     │
│          │                          │
│     ┌────┴────┐                     │  ← 角色头像
│     │   🤖    │                     │
│     └─────────┘                     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  📘 基础语法 - 第1单元       │    │  ← UnitBanner
│  │  Master the fundamentals    │    │
│  └─────────────────────────────┘    │
│                                     │
│           ┌─────┐                   │  ← 路径节点1
│           │ ☕  │  JVM Intro        │    (居中)
│           └─────┘                   │
│             │                       │
│     ┌───────┘                       │  ← 路径节点2
│     │  🗑️   │  Garbage Coll        │    (左侧)
│     └───────┘                       │
│             │                       │
│           ┌─┴───┐                   │  ← 路径节点3
│           │ 📦  │  (宝箱/测验)      │    (居中)
│           └─────┘                   │
│             │                       │
│           ┌─┴───┐                   │  ← 路径节点4
│           │ 🌲  │  Threads         │    (居中，当前激活)
│           └─────┘                   │    (粉色脉冲动画)
│             │                       │
│   ┌─────────┘                       │  ← 路径节点5
│   │ 🔒 📊 │  Collections          │    (右侧，锁定)
│   └─────────┘                       │
│             │                       │
│   ┌─────────┐                       │  ← 路径节点6
│   │ 🔒 🧠 │  OS Kernel            │    (左侧，锁定)
│   └─────────┘                       │
│                                     │
├─────────────────────────────────────┤
│  🏠  🎯  📊  🛒                     │  ← NeoBottomNav
└─────────────────────────────────────┘
```

### 路径节点状态设计

| 状态 | 视觉表现 | 交互 |
|------|----------|------|
| completed | 主色背景 + 白色图标 + 无阴影偏移 | 可点击，显示"复习" |
| unlocked | 主色背景 + 图标 + 硬阴影 | 可点击，进入答题 |
| current | 粉色背景 + 脉冲动画 + 硬阴影 | 可点击，继续学习 |
| locked | 灰色背景 + 锁定图标 + 灰色阴影 | 不可点击，显示提示 |

### 路径连线设计

```dart
// 垂直虚线，连接各节点
Container(
  width: 14,
  color: pathLineColor,
  child: CustomPaint(
    painter: DashedLinePainter(
      completedSegments: completedNodeCount,
      totalSegments: totalNodeCount,
    ),
  ),
)
```

## 组件设计

### PathNodeWidget

```dart
class PathNodeWidget extends StatelessWidget {
  final PathNodeModel node;
  final Alignment alignment; // 节点对齐：left/center/right
  final VoidCallback? onTap;

  // 根据状态返回不同样式
  BoxDecoration _getDecoration() {
    switch (node.status) {
      case NodeStatus.completed:
        return NeoBrutalTheme.createDecoration(
          color: NeoBrutalTheme.primary,
          shadow: NeoBrutalTheme.shadowNodeActive,
        );
      case NodeStatus.unlocked:
        return NeoBrutalTheme.createDecoration(
          color: _getNodeColor(),
          shadow: NeoBrutalTheme.shadowNodeActive,
        );
      case NodeStatus.locked:
        return BoxDecoration(
          color: NeoBrutalTheme.lockedGray,
          border: Border.all(color: Colors.grey.shade300, width: 3),
          borderRadius: BorderRadius.circular(999),
        );
    }
  }
}
```

### CharacterDialogWidget

```dart
class CharacterDialogWidget extends StatelessWidget {
  final String message;
  final String characterIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 对话框
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: NeoBrutalTheme.charcoal, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(message),
        ),
        // 小三角
        Positioned(
          bottom: -12,
          child: CustomPaint(
            painter: TrianglePainter(),
          ),
        ),
        // 角色头像
        Positioned(
          top: 80,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NeoBrutalTheme.charcoal, width: 3),
            ),
            child: Text(characterIcon),
          ),
        ),
      ],
    );
  }
}
```

## API 设计

### 获取技术栈学习路径

```typescript
GET /api/paths/:techStack

Response:
{
  "id": "path_js",
  "techStack": "JavaScript",
  "title": "JavaScript核心",
  "subtitle": "从基础到进阶",
  "characterIcon": "🗡️",
  "characterDialog": "准备好斩题了吗？",
  "categories": [
    {
      "id": "cat_js_basic",
      "name": "基础语法",
      "icon": "📘",
      "color": "#58CC02",
      "order": 1,
      "totalNodes": 5,
      "completedNodes": 3
    }
  ]
}
```

### 获取分类路径节点

```typescript
GET /api/paths/:techStack/categories/:categoryId/nodes

Response:
{
  "categoryId": "cat_js_basic",
  "nodes": [
    {
      "id": "node_js_var",
      "title": "变量与作用域",
      "icon": "☕",
      "color": "primary",
      "order": 1,
      "status": "completed",
      "questionIds": ["q001", "q002", "q003"],
      "estimatedMinutes": 10
    }
  ]
}
```

### 标记节点完成

```typescript
POST /api/paths/nodes/:nodeId/complete

Body:
{
  "userId": "user_123",
  "correctCount": 3,
  "totalCount": 3
}

Response:
{
  "success": true,
  "unlockedNodes": ["node_js_closure"],
  "achievement": null
}
```

## 数据库设计

### learning_paths 表

```sql
CREATE TABLE learning_paths (
  id VARCHAR(50) PRIMARY KEY,
  tech_stack VARCHAR(50) NOT NULL,
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200),
  character_icon VARCHAR(10) DEFAULT '🗡️',
  character_dialog VARCHAR(200) DEFAULT '准备好斩题了吗？',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### path_categories 表

```sql
CREATE TABLE path_categories (
  id VARCHAR(50) PRIMARY KEY,
  path_id VARCHAR(50) REFERENCES learning_paths(id),
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(10),
  color VARCHAR(20) DEFAULT '#58CC02',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### path_nodes 表

```sql
CREATE TABLE path_nodes (
  id VARCHAR(50) PRIMARY KEY,
  category_id VARCHAR(50) REFERENCES path_categories(id),
  title VARCHAR(100) NOT NULL,
  icon VARCHAR(10),
  color VARCHAR(20) DEFAULT 'primary',
  sort_order INTEGER DEFAULT 0,
  question_ids TEXT[], -- PostgreSQL array
  prerequisite_node_id VARCHAR(50) REFERENCES path_nodes(id),
  estimated_minutes INTEGER DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### user_path_progress 表

```sql
CREATE TABLE user_path_progress (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  node_id VARCHAR(50) REFERENCES path_nodes(id),
  status VARCHAR(20) DEFAULT 'locked', -- locked/unlocked/completed
  correct_count INTEGER DEFAULT 0,
  total_count INTEGER DEFAULT 0,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, node_id)
);
```

## 路由设计

```dart
// main.dart 路由配置
onGenerateRoute: (settings) {
  if (settings.name == '/path-categories') {
    final techStack = settings.arguments as String;
    return DuoPageTransition(
      child: PathCategoryPage(techStack: techStack),
    );
  }
  if (settings.name == '/path-map') {
    final args = settings.arguments as Map<String, dynamic>;
    return DuoPageTransition(
      child: LearningPathMapPage(
        techStack: args['techStack'],
        categoryId: args['categoryId'],
      ),
    );
  }
  // ... 其他路由
}
```

## 风险 / 权衡

| 风险 | 缓解措施 |
|------|----------|
| 路径数据维护成本 | 提供管理后台，支持可视化编辑路径 |
| 用户被锁定在路径中 | 支持"试玩"模式，允许预览锁定节点 |
| 与现有答题流程冲突 | 保持QuestionPage兼容，新增nodeId参数 |
| 性能问题（大量节点） | 分页加载，虚拟列表渲染 |

## 待决问题

- [ ] 是否支持用户自定义学习路径？
- [ ] 是否需要路径完成后的证书/徽章？
- [ ] 是否支持路径推荐（根据用户历史）？
