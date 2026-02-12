import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/neo_brutal_theme.dart';
import '../widgets/neo/neo_bottom_nav.dart';
import '../widgets/neo/neo_container.dart';
import '../widgets/neo/neo_stat_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const topics = ['JavaScript', 'React', 'Vue'];

  static const topicProgress = {
    'JavaScript': 5,
    'React': 3,
    'Vue': 2,
  };

  static const topicDifficulty = {
    'JavaScript': '简单',
    'React': '中等',
    'Vue': '中等',
  };

  static const topicIcons = {
    'JavaScript': '⚡',
    'React': '⚛️',
    'Vue': '🌿',
  };

  static const topicColors = {
    'JavaScript': Color(0xFFF7DF1E),
    'React': Color(0xFF61DAFB),
    'Vue': Color(0xFF4FC08D),
  };

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String _selectedNavId = 'home';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部统计栏
            NeoStatBar.standard(
              streak: 5,
              accuracy: 0.85,
              totalQuestions: 100,
              xp: 1250,
            ),

            // 主内容区
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 快捷操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.book,
                            label: '错题本',
                            color: NeoBrutalTheme.fire,
                            onTap: () =>
                                Navigator.pushNamed(context, '/wrong-book'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.bar_chart,
                            label: '学习报告',
                            color: NeoBrutalTheme.primary,
                            onTap: () => Navigator.pushNamed(
                                context, '/learning-report'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 标题
                    Text(
                      '选择主题',
                      style: NeoBrutalTheme.styleHeadlineMedium,
                    ),
                    const SizedBox(height: 16),

                    // 主题列表
                    Expanded(
                      child: ListView.separated(
                        itemCount: HomePage.topics.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final topic = HomePage.topics[index];
                          final completedCount =
                              HomePage.topicProgress[topic] ?? 0;
                          final difficulty = HomePage.topicDifficulty[topic];
                          final icon = HomePage.topicIcons[topic] ?? '📚';
                          final color = HomePage.topicColors[topic] ??
                              NeoBrutalTheme.primary;
                          final start = (index * 0.12).clamp(0.0, 0.6);
                          final animation = CurvedAnimation(
                            parent: _controller,
                            curve:
                                Interval(start, 1, curve: Curves.easeOutCubic),
                          );

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(animation),
                              child: _TopicCard(
                                topic: topic,
                                icon: icon,
                                color: color,
                                completedCount: completedCount,
                                totalCount: 10,
                                difficulty: difficulty,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/path-categories',
                                    arguments: topic,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 底部导航
            NeoBottomNav(
              items: defaultNavItems,
              selectedId: _selectedNavId,
              onTap: (id) {
                setState(() => _selectedNavId = id);
                // 导航逻辑
                if (id == 'path') {
                  Navigator.pushNamed(context, '/dashboard');
                } else if (id == 'achievements') {
                  Navigator.pushNamed(context, '/achievements');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: NeoBrutalTheme.durationPress,
        curve: NeoBrutalTheme.curvePress,
        transform: Matrix4.translationValues(
          _isPressed ? 4 : 0,
          _isPressed ? 4 : 0,
          0,
        ),
        child: NeoContainer(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shadow: _isPressed
              ? NeoBrutalTheme.shadowPressed
              : NeoBrutalTheme.shadowMd,
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 32),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: NeoBrutalTheme.styleBodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.icon,
    required this.color,
    required this.completedCount,
    required this.totalCount,
    this.difficulty,
    this.onTap,
  });

  final String topic;
  final String icon;
  final Color color;
  final int completedCount;
  final int totalCount;
  final String? difficulty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = completedCount / totalCount;

    return NeoContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSm),
              border: Border.all(
                color: NeoBrutalTheme.charcoal,
                width: NeoBrutalTheme.borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  style: NeoBrutalTheme.styleHeadlineSmall.copyWith(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                if (difficulty != null)
                  Text(
                    '难度: $difficulty',
                    style: NeoBrutalTheme.styleBodyMedium.copyWith(
                      color: NeoBrutalTheme.charcoal.withOpacity(0.6),
                    ),
                  ),
                const SizedBox(height: 8),

                // 进度条
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.pathLine,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: NeoBrutalTheme.charcoal,
                      width: 1,
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: NeoBrutalTheme.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount/$totalCount 完成',
                  style: NeoBrutalTheme.styleLabel.copyWith(
                    color: NeoBrutalTheme.charcoal.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // 箭头
          const Icon(
            Icons.chevron_right,
            color: NeoBrutalTheme.charcoal,
          ),
        ],
      ),
    );
  }
}
