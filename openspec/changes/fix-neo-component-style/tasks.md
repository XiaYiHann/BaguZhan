# 实施任务清单

## 1. NeoStatBar 修复
- [x] 1.1 每个统计项包装为 NeoCard（白色背景+边框+阴影）
- [x] 1.2 确保图标颜色正确（火焰橙、主色绿、辅助蓝、钻石紫）
- [x] 1.3 文字大小设置为 12px font-bold

## 2. NeoUserProfileBar 新增
- [x] 2.1 创建 NeoUserProfileBar 组件
- [x] 2.2 黑色背景 (#2D3436) + 白色文字
- [x] 2.3 左侧头像（圆形+边框）
- [x] 2.4 用户名 + 状态指示器（绿点+文字）
- [x] 2.5 右侧等级徽章（半透明白色背景）

## 3. NeoProgressButton 修复
- [ ] 3.1 图标改为 `Icons.star`
- [ ] 3.2 文案改为 `SLASH!`
- [ ] 3.3 确保按钮有硬阴影和按下效果

## 4. NeoUnitBanner 修复
- [ ] 4.1 "CURRENT MISSION" 标签改为 10px
- [ ] 4.2 主标题改为黑色（HTML设计用黑色而非白色）

## 5. 学习路径组件
- [ ] 5.1 创建 NeoPathNode 组件
- [ ] 5.2 创建 NeoPathConnection 组件（垂直连接线）
- [ ] 5.3 节点状态：已完成（绿色）、进行中（粉色）、锁定（灰色）

## 6. 页面集成
- [ ] 6.1 HomePage 添加 NeoUserProfileBar
- [ ] 6.2 ProgressDashboardPage 修复中央按钮
- [ ] 6.3 LearningPathMapPage 使用新组件重构

## 7. 测试验证
- [ ] 7.1 Flutter analyze 无错误
- [ ] 7.2 对比 HTML 设计稿视觉一致性
