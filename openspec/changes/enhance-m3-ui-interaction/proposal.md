# 变更：M3 UI 交互与视觉增强

## 为什么

M1/M2 阶段已完成基础 UI 和答题流程。当前设计遵循多邻国风格，但仍有以下可优化空间：

1. **首页交互反馈不足**：快速操作按钮缺少按下状态反馈
2. **信息密度不够**：主题列表未展示学习进度，用户无法直观了解完成度
3. **答题激励感弱**：缺少连击提示和视觉庆祝反馈
4. **颜色系统待完善**：功能色、主题色映射未系统化
5. **页面过渡单一**：缺少流畅的页面切换动画

## 变更内容

### 1. 首页体验优化
- 快速操作按钮添加按下状态动画（硬阴影位移 + 触觉反馈）
- 主题卡片添加学习进度条显示（已完成/总数）
- 主题卡片添加难度标签视觉区分

### 2. 答题页交互增强
- 提交按钮添加脉冲动画提示（可点击时）
- 选项卡选中添加微缩放动画（1.02x）
- 进度条添加连击提示（连续答对 ≥ 3 题时显示火焰图标）

### 3. 反馈面板优化
- 正确/错误状态添加表情动画（🎉/💪）
- 表情使用弹性缩放曲线（Curves.elasticOut）

### 4. 颜色系统扩展
- 新增功能色：错题本橙、报告绿、连击金
- 新增难度等级色：简单绿、中等蓝、困难紫
- 新增主题色彩映射：JavaScript 黄、React 蓝、Vue 绿等

### 5. 页面过渡动画
- 添加自定义页面路由过渡（淡入 + 轻微上滑）
- 统一使用 easeOutCubic 缓动曲线

## 影响

- 受影响规范：
  - `ui-components` - 新增颜色、组件交互状态
  - `question-flow` - 新增连击统计逻辑
- 受影响代码：
  - `lib/core/theme/app_theme.dart` - 扩展颜色系统
  - `lib/presentation/pages/home_page.dart` - 快速按钮、主题卡片优化
  - `lib/presentation/pages/question_page.dart` - 提交按钮、进度条优化
  - `lib/presentation/widgets/option_card.dart` - 选中动画增强
  - `lib/presentation/widgets/feedback_panel.dart` - 表情动画
  - `lib/presentation/providers/question_provider.dart` - 连击计数
  - 新增 `lib/routes/page_transitions.dart` - 页面过渡

## 设计原则

- **最小改动**：基于现有组件扩展，不重构架构
- **多邻国风格一致**：保持硬阴影、圆角、扁平化特征
- **性能优先**：动画时长控制在 150-300ms
- **可访问性**：保持足够的颜色对比度

## 验收标准

- [ ] 快速操作按钮按下时有 2px 位移和阴影变化
- [ ] 主题卡片显示进度条（已完成/总数）
- [ ] 连击 ≥ 3 题时进度条显示火焰图标
- [ ] 提交按钮可点击时有脉冲动画
- [ ] 反馈面板显示表情动画（弹性效果）
- [ ] 页面过渡使用淡入 + 上滑效果
- [ ] 所有动画流畅，无卡顿（60fps）
- [ ] 颜色对比度符合 WCAG AA 标准

## 参考资源

### 设计灵感
- [Duolingo Design System](https://design.duolingo.com/)
- [Material Design Motion](https://m3.material.io/styles/motion/overview)

### Flutter 动画最佳实践
- [Flutter Animations Guide](https://docs.flutter.dev/development/ui/animations)
- [Implicit Animations in Flutter](https://docs.flutter.dev/development/ui/animations/implicit-animations)

### 游戏化设计
- [Duolingo Streak System Analysis](https://blog.duolingo.com/how-levs-streak-holds-people-accountable/)
- [Gamification in Learning Apps](https://www.nngroup.com/articles/using-ui-animation-to-delight-users/)
