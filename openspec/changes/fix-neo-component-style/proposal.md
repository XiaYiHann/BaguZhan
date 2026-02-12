# 变更：修复 Neo-Brutal 组件样式问题

## 为什么

M5 Neo-Brutal 主题系统和重构提案 `refactor-frontend-neo-style` 已完成基本实现，但通过审计发现多个关键组件与用户提供的 HTML 设计稿不一致：

1. **NeoStatBar** - 缺少白色卡片背景、边框和阴影
2. **用户信息头部栏** - 完全缺失（黑色背景+头像+用户名+等级徽章）
3. **中央按钮** - 图标使用 `play_arrow` 而非 `star`，文案为 `START` 而非 `SLASH!`
4. **学习路径地图** - 页面存在但样式不完整

## 变更内容

### 修改
- **NeoStatBar** - 每个统计项改为独立的白色卡片（NeoCard）样式
- **NeoProgressButton** - 修改图标为星星，文案改为 "SLASH!"
- **NeoUnitBanner** - 修复标签文字样式（10px, 黑色60%透明度）

### 新增
- **NeoUserProfileBar** - 用户信息头部栏组件（黑色背景+头像+用户名+状态+等级）
- **NeoPathNode** - 学习路径节点组件（圆形+状态样式）
- **NeoPathConnection** - 路径连接线组件

### 重构
- **HomePage** - 添加 NeoUserProfileBar 到顶部
- **ProgressDashboardPage** - 修复中央按钮样式

## 影响

- 受影响规范：ui-components
- 受影响代码：
  - `baguzhan/lib/presentation/widgets/neo/neo_stat_bar.dart`
  - `baguzhan/lib/presentation/widgets/neo/neo_progress_ring.dart`
  - `baguzhan/lib/presentation/widgets/neo/neo_unit_banner.dart`
  - `baguzhan/lib/presentation/pages/home_page.dart`
  - `baguzhan/lib/presentation/pages/progress_dashboard_page.dart`
  - `baguzhan/lib/presentation/pages/learning_path_map_page.dart`

## 参考资料

- 用户提供的 HTML 设计稿（4个页面）
- M5 归档提案：`openspec/changes/archive/2026-01-30-add-m5-neo-brutal-theme/`
