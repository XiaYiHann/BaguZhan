# 变更：M3 UI 视觉与交互优化

## 为什么

M1/M2 已实现完整答题流程并接入后端题库，但整体体验仍偏“功能可用”，缺少淡色系 + 多邻国风格的轻松感与流畅反馈。需要在不改变核心业务语义的前提下，通过主题、动效与多尺寸适配提升可读性、反馈强度与一致性。

## 变更内容

- 统一主题与组件视觉（淡色系、多邻国风格层级）
- 为关键交互补齐动效与触感反馈（选项、反馈面板、进度变化、页面关键状态）
- 完成多尺寸适配（小屏可读、横屏/平板布局）
- 优化加载/错误/空状态体验
- 添加必要的 UI 回归测试（Widget/Golden）

## 影响

- 受影响规范：
  - `flutter-app`（主题配置与基础体验）
  - `ui-components`（组件视觉/交互/响应式）
  - `testing`（UI 回归测试）
- 受影响代码：
  - `baguzhan/lib/core/theme/`
  - `baguzhan/lib/presentation/pages/`
  - `baguzhan/lib/presentation/widgets/`
  - `baguzhan/test/`
