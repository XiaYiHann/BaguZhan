# M3 UI 交互增强 - 设计文档

## 架构设计

### 组件层次

```
HomePage
├── _QuickActionButton (增强: 按下状态)
└── TopicListView
    └── TopicCard (新增: 进度条、难度标签)

QuestionPage
├── ProgressBar (增强: 连击提示)
├── QuestionCard
├── OptionCard (增强: 选中缩放)
├── SubmitButton (增强: 脉冲动画)
└── FeedbackPanel (增强: 表情动画)

PageRouter
└── DuoPageTransition (新增)
```

## 状态管理

### QuestionProvider 扩展

```dart
class QuestionProvider extends ChangeNotifier {
  // 现有状态...
  int _currentStreak = 0;      // 当前连击数
  int _maxStreak = 0;          // 最大连击数

  int get currentStreak => _currentStreak;
  int get maxStreak => _maxStreak;

  void submitAnswer() {
    // 现有逻辑...
    if (isCorrect) {
      _currentStreak++;
      if (_currentStreak > _maxStreak) {
        _maxStreak = _currentStreak;
      }
    } else {
      _currentStreak = 0;
    }
    notifyListeners();
  }

  void resetStreak() {
    _currentStreak = 0;
    notifyListeners();
  }
}
```

## 动画系统

### 新增时长与缓动

```dart
class AppTheme {
  // 现有...
  static const Duration durationElastic = Duration(milliseconds: 400);
  static const Duration durationPulse = Duration(milliseconds: 800);
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curvePulse = Curves.easeInOutSine;
}
```

### 页面过渡实现

```dart
class DuoPageTransition extends PageRouteBuilder<T> {
  final Widget child;

  DuoPageTransition({required this.child})
      : super(
          pageBuilder: (context, animation, _) => child,
          transitionDuration: AppTheme.durationPanel,
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppTheme.curvePanel,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
```

## 颜色系统扩展

### 新增颜色常量

```dart
class AppTheme {
  // 现有颜色...

  // 功能色
  static const Color wrongBookColor = Color(0xFFFF9600);
  static const Color reportColor = Color(0xFF82C91E);
  static const Color streakColor = Color(0xFFFFC800);

  // 难度等级色
  static const Color difficultyEasy = Color(0xFF58CC02);
  static const Color difficultyMedium = Color(0xFF1CB0F6);
  static const Color difficultyHard = Color(0xFFCE82FF);

  // 主题映射色
  static const Map<String, Color> topicColors = {
    'JavaScript': Color(0xFFF7DF1E),
    'React': Color(0xFF61DAFB),
    'Vue': Color(0xFF4FC08D),
    'TypeScript': Color(0xFF3178C6),
    'Node.js': Color(0xFF339933),
    'CSS': Color(0xFF1572B6),
    'HTML': Color(0xFFE34F26),
    'Java': Color(0xFF007396),
  };

  // 语义背景色
  static const Color streakBackground = Color(0xFFFFF4CC);
}
```

## 组件设计细节

### 快速操作按钮

| 状态 | 阴影偏移 | 缩放 | 触觉反馈 |
|------|----------|------|----------|
| 默认 | (0, 4) | 1.0 | - |
| 按下 | (0, 0) | 1.0 | lightImpact |

### 主题卡片进度条

```
┌─────────────────────────────────────┐
│ JavaScript          5/10            │
│ ████████░░░░                         │
└─────────────────────────────────────┘
```

- 进度条高度: 8px
- 圆角: 4px
- 填充色: duoGreen
- 背景色: borderGray

### 连击徽章

```
┌─────┐
│ 🔥 3│  (连击 ≥ 3 时显示)
└─────┘
```

- 背景: streakColor
- 边框: 2px 白色
- 圆角: 20px (胶囊形)
- 内边距: (12, 6)

### 提交按钮脉冲

```dart
AnimatedContainer(
  duration: AppTheme.durationPulse,
  decoration: BoxDecoration(
    boxShadow: isEnabled
      ? [
          BoxShadow(
            color: AppTheme.duoGreen.withOpacity(0.4),
            offset: Offset(0, 4),
            blurRadius: _pulseValue ? 12 : 8,
          ),
        ]
      : [AppTheme.shadowDown],
  ),
  // ...
)
```

### 表情动画

```dart
AnimatedScale(
  scale: _showEmoji ? 1.0 : 0.0,
  duration: AppTheme.durationElastic,
  curve: AppTheme.curveElastic,
  child: Text(
    isCorrect ? '🎉' : '💪',
    style: TextStyle(fontSize: 48),
  ),
)
```

## 性能考虑

1. **动画复用**：使用 `AnimatedContainer` / `AnimatedScale` 而非手动 AnimationController
2. **状态分离**：连击状态在 Provider 中管理，避免 UI 逻辑混杂
3. **常量提取**：所有颜色、时长、曲线统一定义在 AppTheme

## 可访问性

### 对比度验证

| 颜色组合 | 对比度 | 标准 |
|----------|--------|------|
| textPrimary on background | 11.1:1 | AAA |
| textSecondary on background | 5.1:1 | AA |
| duoGreen on white | 3.1:1 | AA Large |

### 触觉反馈

- 所有可点击元素使用 `HapticFeedback.lightImpact()`
- 成功/失败可考虑使用 `mediumImpact()` / `heavyImpact()`
