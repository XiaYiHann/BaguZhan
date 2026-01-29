# flutter-app Specification

## Purpose
TBD - created by archiving change add-m1-basic-ui. Update Purpose after archive.
## 需求
### Requirement: Flutter 应用初始化

系统 MUST 提供完整配置的 Flutter 项目结构，支持跨平台（iOS/Android）开发。

#### Scenario: 项目创建成功

- **当** 执行 `flutter create baguzhan` 并配置依赖
- **那么** 项目包含以下目录结构：
  - `lib/core/` - 常量、主题、工具
  - `lib/data/` - 数据模型、仓储、数据源
  - `lib/domain/` - 领域实体、用例
  - `lib/presentation/` - 页面、组件、状态管理
  - `test/` - 测试文件

#### Scenario: 依赖配置正确

- **当** 查看 `pubspec.yaml`
- **那么** 包含以下核心依赖：
  - provider（状态管理）
  - dio（网络请求，预留）
  - shared_preferences（本地存储）
  - flutter_svg（SVG 图标）

### Requirement: 分层架构

系统 MUST 采用清晰的分层架构，实现职责分离。

#### Scenario: 数据层独立

- **当** 需要更换数据源（本地 → API）
- **那么** 只需实现新的 Repository，不修改 UI 层代码

#### Scenario: 状态管理层隔离

- **当** UI 组件需要访问题目数据
- **那么** 通过 Provider 获取，不直接访问数据层

### Requirement: 代码规范配置

系统 MUST 配置统一的代码规范检查。

#### Scenario: Lint 规则生效

- **当** 代码不符合规范
- **那么** IDE 显示警告/错误提示
- **并且** `flutter analyze` 报告问题

### 需求：主题配置与一致性

系统 MUST 将主题（颜色、文字层级、圆角、阴影）集中管理，并在应用内一致使用。

#### 场景：主题入口统一

- **当** 应用启动
- **那么** MaterialApp 使用统一的 ThemeData
- **并且** 核心页面与组件不直接硬编码颜色常量（通过主题/Token 访问）

