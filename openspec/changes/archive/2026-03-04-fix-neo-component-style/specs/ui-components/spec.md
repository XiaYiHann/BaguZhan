# UI Components Specification Increment

## MODIFIED Requirements

### Requirement: NeoStatBar

现有 NeoStatBar MUST 修改为每个统计项使用独立的卡片样式。

#### Scenario: 统计项卡片样式

- **当** 渲染 NeoStatBar
- **那么** 每个统计项显示为白色背景卡片，带有 3px 黑色边框和 4px 硬阴影

#### Scenario: 统计项布局

- **当** 显示 4 个统计项
- **那么** 横向平分宽度，每个卡片之间间距 8px

## ADDED Requirements

### Requirement: NeoUserProfileBar

系统 MUST 提供用户信息头部栏组件。

#### Scenario: 显示用户信息栏

- **当** 页面顶部显示用户信息
- **那么** 显示黑色背景条，包含头像、用户名、状态指示器和等级徽章

#### Scenario: 用户名显示

- **当** 显示用户名
- **那么** 使用白色粗体文字，字号 16px

#### Scenario: 等级徽章

- **当** 显示等级徽章
- **那么** 显示半透明白色背景的圆角矩形，包含等级数字

### Requirement: NeoPathNode

系统 MUST 提供学习路径节点组件。

#### Scenario: 已完成节点

- **当** 节点状态为已完成
- **那么** 显示绿色圆形背景，白色图标，带硬阴影

#### Scenario: 进行中节点

- **当** 节点状态为进行中
- **那么** 显示粉色圆形背景，带脉冲动画效果

#### Scenario: 锁定节点

- **当** 节点状态为锁定
- **那么** 显示灰色圆形背景，虚线边框，灰色图标

### Requirement: NeoPathConnection

系统 MUST 提供路径连接线组件。

#### Scenario: 垂直连接线

- **当** 渲染节点之间的连接
- **那么** 显示灰色垂直线条，宽度 14px，带黑色边框
