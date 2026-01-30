# 变更：添加学习路径地图系统

## 为什么

当前应用的技术栈选择（如JavaScript、React、Vue）直接进入答题流程，缺乏结构化的学习路径引导。用户需要：

1. **清晰的学习路线** - 了解技术栈内各知识点的依赖关系和进阶顺序
2. **游戏化闯关体验** - 通过可视化的路径节点，增强学习成就感
3. **进度可视化** - 直观看到自己在整个技术栈中的学习进度
4. **模块化学习** - 可以按子目录（如JavaScript基础、闭包、原型链）分阶段学习

参考用户提供的HTML原型设计，采用Neo-Brutal风格的垂直路径地图，结合游戏化元素（角色、对话框、锁定/解锁状态），提升学习体验。

## 变更内容

### 新增

#### 数据模型
- **LearningPathModel** - 学习路径数据模型，定义技术栈的完整学习路线
- **PathNodeModel** - 路径节点模型，包含关卡信息、解锁条件、题目关联
- **PathCategoryModel** - 路径分类模型，技术栈下的子目录（如JavaScript → 基础、进阶、ES6+）

#### 页面
- **LearningPathMapPage** - 学习路径地图页面（垂直闯关地图）
  - 顶部：角色对话框 + 技术栈标题横幅
  - 中部：垂直路径节点（交替左右布局）
  - 底部：底部导航
- **PathCategoryPage** - 路径分类页面（子目录列表）
  - 展示技术栈下的各个分类（基础、进阶、高级）
  - 每个分类显示进度和题目数量
- **NodeDetailPage** - 节点详情页面
  - 显示关卡信息、题目列表、开始答题按钮

#### 组件
- **PathNodeWidget** - 路径节点组件
  - 支持多种状态：已解锁、已完成、锁定
  - 硬阴影 + 按压效果
  - 图标 + 标签展示
- **PathLinePainter** - 路径连线绘制器
  - 垂直虚线连接各节点
  - 已完成的节点连线高亮
- **CharacterDialogWidget** - 角色对话框组件
  - 漫画风格对话框
  - 动态提示文本
- **PathProgressBanner** - 路径进度横幅
  - 显示当前技术栈进度
  - Neo-Brutal风格卡片

#### BFF API
- `GET /api/paths/:techStack` - 获取技术栈学习路径
- `GET /api/paths/:techStack/categories` - 获取路径分类
- `GET /api/paths/nodes/:nodeId/questions` - 获取节点关联题目
- `POST /api/paths/nodes/:nodeId/complete` - 标记节点完成

### 修改

#### 现有页面调整
- **HomePage** - 点击技术栈后进入 PathCategoryPage（而非直接进入答题）
- **QuestionPage** - 支持从特定路径节点加载题目（带nodeId参数）

#### 数据库
- 新增 `learning_paths` 表 - 存储路径定义
- 新增 `path_nodes` 表 - 存储路径节点
- 新增 `path_categories` 表 - 存储路径分类
- 新增 `user_path_progress` 表 - 存储用户路径进度

## 影响

- 受影响规范：ui-components, question-flow, flutter-app, bff, database
- 受影响代码：
  - `baguzhan/lib/presentation/pages/` - 新增路径地图页面
  - `baguzhan/lib/presentation/widgets/path/` - 新增路径组件
  - `baguzhan/lib/data/models/` - 新增路径数据模型
  - `server/src/routes/paths.ts` - 新增路径API
  - `server/src/database/sql/schema.sql` - 新增路径表

## 设计原则

- **保持Neo-Brutal风格** - 硬阴影、粗边框、高对比度配色
- **游戏化体验** - 角色引导、闯关解锁、进度可视化
- **渐进式解锁** - 按顺序解锁节点，支持跳转到已解锁节点
- **与现有系统兼容** - 复用现有题目系统，路径节点关联题目ID

## 参考资料

- 用户提供的HTML原型设计（垂直路径地图）
- 现有Neo-Brutal组件库（NeoContainer, NeoButton等）
- 现有题目数据模型和答题流程
