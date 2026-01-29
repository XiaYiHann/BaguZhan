# M3 UI 视觉与交互优化 - 任务清单

## 1. 实施

- [x] 1.1 定义主题扩展（颜色/圆角/阴影/字号/间距 token），并在现有 `AppTheme` 中落地
- [x] 1.2 OptionCard：增加“物理按压”反馈（按下位移 + 阴影/边框过渡 + 轻触感反馈）
- [x] 1.3 FeedbackPanel：增加底部弹出动效（弹性曲线），并确保长文本可滚动
- [x] 1.4 ProgressBar：改为更符合多邻国风格的胶囊/分段样式，并添加进度过渡动画
- [x] 1.5 HomePage：主题列表入场动效（staggered reveal）
- [x] 1.6 QuestionPage：多尺寸适配（小屏布局压缩、>=600dp 双栏/更大留白）
- [x] 1.7 ResultPage：统计数字动效（计数器），并优化按钮层级
- [x] 1.8 加载/错误/空状态组件化（骨架/占位/提示文案与按钮）
- [x] 1.9 补齐/更新 Widget 测试覆盖关键状态与交互（至少 OptionCard/FeedbackPanel/ProgressBar）
- [x] 1.10 添加 Golden 测试覆盖关键视觉状态（OptionCard/ProgressBar/FeedbackPanel）
- [x] 1.11 验证：`flutter test`
- [x] 1.12 验证：`flutter analyze`
