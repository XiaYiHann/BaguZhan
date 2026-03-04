# 设计文档：Neo-Brutal 组件样式修复

## 上下文

用户提供的 HTML 设计稿包含特定的 Neo-Brutal 样式细节，当前实现存在多处不一致。

## 设计决策

### 1. 统计卡片 (NeoStatBar)

每个统计项必须是独立的白色卡片：

```dart
// 正确结构
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: NeoBrutalTheme.charcoal, width: 2),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 0)],
  ),
  child: Column(...),
)
```

### 2. 用户信息头部栏

黑色圆角矩形背景，包含：
- 头像：左侧，圆形，带绿色边框
- 用户名：白色粗体
- 状态：绿点 + 文字（如 "Learning JavaScript"）
- 等级：右侧，半透明白色背景

### 3. 中央按钮

- 图标：`Icons.star` (星星)
- 文案：`SLASH!` (全大写+感叹号)
- 颜色：绿色背景 + 白色图标 + 黑色文案

### 4. 路径节点

- 已完成：绿色圆形，白色图标
- 进行中：粉色圆形，脉冲动画
- 锁定：灰色圆形，灰色图标

## 视觉对比

| 组件 | HTML设计 | 当前实现 | 状态 |
|------|----------|----------|------|
| 统计项 | 白色卡片+边框+阴影 | 仅图标+文字 | ❌ |
| 用户栏 | 黑色条+头像+等级 | 缺失 | ❌ |
| 中央按钮 | 星星+SLASH! | play+START | ❌ |
| 路径节点 | 圆形+连接线 | 不完整 | ❌ |

## 待决问题

- 头像图片来源（使用默认图标占位）
