# UI Components Specification Increment

## ADDED Requirements

### Requirement: LearningPathModel 数据模型

系统 MUST 定义学习路径数据模型，描述技术栈的完整学习路线。

#### Scenario: 模型包含完整字段

- **当** 创建 LearningPathModel 实例
- **那么** 包含以下字段：
  - id (String) - 路径唯一标识
  - techStack (String) - 技术栈名称
  - title (String) - 路径标题
  - subtitle (String) - 路径副标题
  - characterIcon (String) - 角色图标
  - characterDialog (String) - 角色对话框文本
  - categories (List<PathCategoryModel>) - 分类列表
  - totalNodes (int) - 总节点数
  - completedNodes (int) - 已完成节点数

### Requirement: PathCategoryModel 数据模型

系统 MUST 定义路径分类模型，描述技术栈下的子目录。

#### Scenario: 分类模型包含完整字段

- **当** 创建 PathCategoryModel 实例
- **那么** 包含以下字段：
  - id (String) - 分类唯一标识
  - name (String) - 分类名称
  - icon (String) - 分类图标
  - color (String) - 主题色
  - order (int) - 排序顺序
  - totalNodes (int) - 总节点数
  - completedNodes (int) - 已完成节点数
  - nodes (List<PathNodeModel>) - 节点列表

### Requirement: PathNodeModel 数据模型

系统 MUST 定义路径节点模型，描述学习路径中的各个关卡。

#### Scenario: 节点模型包含完整字段

- **当** 创建 PathNodeModel 实例
- **那么** 包含以下字段：
  - id (String) - 节点唯一标识
  - title (String) - 节点标题
  - icon (String) - 节点图标
  - color (String) - 节点颜色
  - order (int) - 节点顺序
  - status (NodeStatus) - 节点状态
  - questionIds (List<String>) - 关联题目ID列表
  - prerequisiteNodeId (String?) - 前置节点ID
  - estimatedMinutes (int) - 预计完成时间

#### Scenario: 节点状态枚举

- **当** 定义节点状态
- **那么** 包含以下状态：
  - locked - 锁定状态
  - unlocked - 已解锁
  - completed - 已完成

### Requirement: PathCategoryPage 路径分类页面

系统 MUST 提供路径分类页面，展示技术栈下的各个学习分类。

#### Scenario: 显示分类列表

- **当** 进入 PathCategoryPage
- **那么** 显示该技术栈的所有分类
- **并且** 每个分类显示图标、名称、进度

#### Scenario: 点击分类进入路径地图

- **当** 用户点击某个分类
- **那么** 导航到 LearningPathMapPage
- **并且** 加载该分类的路径节点

### Requirement: LearningPathMapPage 学习路径地图页面

系统 MUST 提供学习路径地图页面，以垂直闯关形式展示学习节点。

#### Scenario: 页面布局

- **当** 用户打开 LearningPathMapPage
- **那么** 按顺序显示：
  - 顶部：统计栏
  - 角色对话框 + 角色头像
  - 单元标题横幅
  - 垂直路径节点（交替左右布局）
  - 底部导航

#### Scenario: 路径节点显示

- **当** 页面加载完成
- **那么** 显示垂直排列的节点
- **并且** 节点交替显示在中心线左右两侧
- **并且** 节点间用垂直虚线连接

#### Scenario: 节点状态展示

- **当** 节点状态不同时
- **那么** 显示不同的视觉样式：
  - completed: 主色背景，无阴影偏移
  - unlocked: 主色背景，硬阴影
  - current: 粉色背景，脉冲动画
  - locked: 灰色背景，锁定图标

#### Scenario: 点击节点

- **当** 用户点击已解锁节点
- **那么** 进入答题页面
- **并且** 加载该节点关联的题目

- **当** 用户点击锁定节点
- **那么** 显示提示信息
- **并且** 不执行跳转

### Requirement: PathNodeWidget 路径节点组件

系统 MUST 提供路径节点组件，支持多种状态展示。

#### Scenario: 已完成节点

- **当** 节点状态为 completed
- **那么** 显示主色背景
- **并且** 显示白色图标
- **并且** 点击后进入复习模式

#### Scenario: 已解锁节点

- **当** 节点状态为 unlocked
- **那么** 显示配置的颜色背景
- **并且** 显示硬阴影效果
- **并且** 点击后进入答题

#### Scenario: 当前节点

- **当** 节点状态为 current（正在学习）
- **那么** 显示粉色背景
- **并且** 显示脉冲动画效果
- **并且** 显示硬阴影

#### Scenario: 锁定节点

- **当** 节点状态为 locked
- **那么** 显示灰色背景
- **并且** 显示锁定图标
- **并且** 不可点击

### Requirement: CharacterDialogWidget 角色对话框组件

系统 MUST 提供角色对话框组件，显示漫画风格的提示文本。

#### Scenario: 显示对话框

- **当** 渲染 CharacterDialogWidget
- **那么** 显示白色背景对话框
- **并且** 显示黑色粗边框
- **并且** 底部显示指向角色的三角形

#### Scenario: 显示角色头像

- **当** 渲染角色头像
- **那么** 显示圆形头像容器
- **并且** 显示硬阴影效果
- **并且** 显示角色图标

### Requirement: PathLinePainter 路径连线绘制器

系统 MUST 提供路径连线绘制器，绘制连接各节点的垂直线。

#### Scenario: 绘制垂直虚线

- **当** 渲染路径连线
- **那么** 绘制垂直虚线
- **并且** 线宽 14px
- **并且** 居中显示

#### Scenario: 已完成段高亮

- **当** 节点已完成
- **那么** 对应连线段显示主色
- **并且** 未完成段显示灰色

## MODIFIED Requirements

### Requirement: HomePage 首页

现有首页 MUST 调整技术栈点击行为，进入路径分类页面而非直接进入答题。

#### Scenario: 点击技术栈

- **当** 用户点击某个技术栈
- **那么** 导航到 PathCategoryPage
- **并且** 传递技术栈名称参数

### Requirement: QuestionPage 答题页

现有答题页 MUST 支持从路径节点加载题目。

#### Scenario: 从节点进入答题

- **当** 从 LearningPathMapPage 进入答题
- **那么** 接收 nodeId 参数
- **并且** 加载该节点关联的题目
- **并且** 答题完成后标记节点完成

#### Scenario: 完成节点答题

- **当** 用户完成节点内所有题目
- **那么** 显示完成提示
- **并且** 解锁下一个节点
- **并且** 可选返回路径地图或继续下一节点
