# M3 UI 交互增强 - 任务清单

## 阶段 1：颜色系统扩展

### 1.1 扩展 AppTheme 颜色定义
- [ ] 在 `lib/core/theme/app_theme.dart` 添加功能色常量
  - [ ] 错题本橙 `wrongBookColor: #FF9600`
  - [ ] 报告绿 `reportColor: #82C91E`
  - [ ] 连击金 `streakColor: #FFC800`
- [ ] 添加难度等级色常量
  - [ ] 简单 `difficultyEasy: #58CC02`
  - [ ] 中等 `difficultyMedium: #1CB0F6`
  - [ ] 困难 `difficultyHard: #CE82FF`
- [ ] 添加主题映射色 Map（JavaScript、React、Vue 等）
- [ ] 添加语义背景色 `streakBackground: #FFF4CC`
- **验证**：运行 `flutter analyze` 无错误

### 1.2 扩展动画常量
- [ ] 添加弹性动画时长 `durationElastic: 400ms`
- [ ] 添加脉冲动画时长 `durationPulse: 800ms`
- [ ] 添加弹性缓动曲线 `curveElastic: elasticOut`
- [ ] 添加脉冲缓动曲线 `curvePulse: easeInOutSine`
- **验证**：新常量与现有风格一致

## 阶段 2：首页体验优化

### 2.1 快速操作按钮按下反馈
- [ ] 修改 `_QuickActionButton` 为 StatefulWidget
- [ ] 添加 `_isPressed` 状态
- [ ] 实现 `onTapDown`/`onTapUp`/`onTapCancel` 处理
- [ ] 添加按下时 2px 位移动画
- [ ] 添加阴影切换（shadowDown ↔ shadowPressed）
- [ ] 添加触觉反馈 `HapticFeedback.lightImpact()`
- **验证**：点击按钮时有下沉效果和触感

### 2.2 主题卡片进度显示
- [ ] 创建 `TopicCard` 组件（扩展 DuoCard）
- [ ] 添加 `completedCount` 和 `totalCount` 参数
- [ ] 实现 `completed/total` 文本显示
- [ ] 实现迷你进度条（8px 高度）
- [ ] 进度条支持 FractionallySizedBox 动画
- [ ] 替换 `HomePage` 中的主题列表项
- **验证**：主题卡片显示进度比例

### 2.3 主题卡片难度标签
- [ ] 为 `TopicCard` 添加 `difficulty` 参数
- [ ] 根据难度显示对应颜色标签
- [ ] 标签使用 Chip 样式
- **验证**：不同难度显示不同颜色

## 阶段 3：答题页交互增强

### 3.1 进度条连击提示
- [ ] 在 `QuestionProvider` 添加 `_currentStreak` 状态
- [ ] 添加 `_maxStreak` 状态
- [ ] 在 `submitAnswer()` 中更新连击计数
- [ ] 答对递增，答错清零
- [ ] 修改 `ProgressBar` 组件
- [ ] 添加 `streak` 参数
- [ ] 连击 ≥ 3 时显示火焰徽章
- [ ] 徽章使用 `streakColor` 背景
- **验证**：连续答对 3 题显示 🔥3

### 3.2 提交按钮脉冲动画
- [ ] 创建 `_PulseButton` 组件
- [ ] 使用 AnimationController 控制脉冲
- [ ] 可点击时阴影脉冲（模糊半径 8-12px）
- [ ] 脉冲使用 `easeInOutSine` 曲线
- [ ] 替换 `QuestionPage` 中的提交按钮
- **验证**：选择选项后按钮有呼吸效果

### 3.3 选项卡选中缩放
- [ ] 修改 `OptionCard` 添加 `AnimatedScale`
- [ ] 选中时缩放至 1.02
- [ ] 使用 `durationFast` 过渡
- **验证**：选中选项时有轻微放大

## 阶段 4：反馈面板优化

### 4.1 表情动画实现
- [ ] 修改 `FeedbackPanel` 添加表情显示区域
- [ ] 使用 `AnimatedScale` 控制表情出现
- [ ] 正确时显示 🎉
- [ ] 错误时显示 💪
- [ ] 使用 `elasticOut` 缓动曲线
- [ ] 表情大小 48px
- **验证**：提交答案后表情弹性弹出

## 阶段 5：页面过渡动画

### 5.1 实现自定义页面过渡
- [ ] 创建 `lib/routes/page_transitions.dart`
- [ ] 实现 `DuoPageTransition` 类
- [ ] 继承 `PageRouteBuilder`
- [ ] 淡入 + 轻微上滑（0.05 偏移）
- [ ] 使用 `easeOutCubic` 曲线
- [ ] 时长使用 `durationPanel`
- **验证**：页面切换流畅自然

### 5.2 应用页面过渡
- [ ] 修改 `main.dart` 路由配置
- [ ] 或使用 `onGenerateRoute` 应用过渡
- [ ] 测试所有页面切换
- **验证**：所有页面切换使用新过渡

## 阶段 6：测试与优化

### 6.1 动画性能测试
- [ ] 使用 Flutter DevTools 性能分析
- [ ] 确保所有动画达到 60fps
- [ ] 检查无明显掉帧
- **验证**：性能测试通过

### 6.2 可访问性验证
- [ ] 检查所有新增颜色的对比度
- [ ] 确保符合 WCAG AA 标准
- [ ] 测试触觉反馈不过度
- **验证**：可访问性检查通过

### 6.3 多尺寸适配测试
- [ ] 测试小屏设备（360dp 宽度）
- [ ] 测试平板设备（600dp+ 宽度）
- [ ] 确保连击徽章不遮挡内容
- **验证**：各尺寸显示正常

## 阶段 7：文档与清理

### 7.1 更新文档
- [ ] 更新 `openspec/specs/ui-components/spec.md`
- [ ] 添加新增组件和状态说明
- [ ] 更新 `openspec/specs/question-flow/spec.md`
- [ ] 添加连击统计逻辑说明
- **验证**：文档与实现一致

### 7.2 代码审查准备
- [ ] 运行 `flutter analyze`
- [ ] 运行 `flutter test`
- [ ] 移除调试代码
- [ ] 统一代码风格
- **验证**：代码质量检查通过

## 依赖关系

```
1.1 → 1.2
      ↓
2.1 → 2.2 → 2.3
      ↓
3.1 (并行: 3.2, 3.3)
      ↓
4.1
      ↓
5.1 → 5.2
      ↓
6.1 → 6.2 → 6.3
      ↓
7.1 → 7.2
```

## 可并行任务

- **阶段 1** 可独立完成
- **阶段 2** 和 **阶段 3** 可并行开发（不同页面）
- **3.2** 和 **3.3** 可并行（不同组件）
- **阶段 5** 可与 **阶段 4** 并行

## 预估工作量

| 阶段 | 预估时间 |
|------|----------|
| 颜色系统扩展 | 0.5h |
| 首页体验优化 | 2h |
| 答题页交互增强 | 2.5h |
| 反馈面板优化 | 1h |
| 页面过渡动画 | 1.5h |
| 测试与优化 | 2h |
| 文档与清理 | 1h |
| **总计** | **10.5h** |
