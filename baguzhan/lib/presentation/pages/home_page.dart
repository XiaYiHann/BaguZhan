import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/duo_card.dart';
import '../widgets/topic_card.dart';

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

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
      appBar: AppBar(title: const Text('八股斩')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.book,
                    label: '错题本',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/wrong-book'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.bar_chart,
                    label: '学习报告',
                    color: Colors.green,
                    onTap: () =>
                        Navigator.pushNamed(context, '/learning-report'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('选择主题', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: HomePage.topics.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final topic = HomePage.topics[index];
                  final completedCount = HomePage.topicProgress[topic] ?? 0;
                  final difficulty = HomePage.topicDifficulty[topic];
                  final start = (index * 0.12).clamp(0.0, 0.6);
                  final animation = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(start, 1, curve: Curves.easeOutCubic),
                  );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: TopicCard(
                        topic: topic,
                        completedCount: completedCount,
                        totalCount: 10,
                        difficulty: difficulty,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/question',
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
        duration: AppTheme.durationPress,
        curve: AppTheme.curvePress,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        child: DuoCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          boxShadow: _isPressed ? [AppTheme.shadowPressed] : [AppTheme.shadowDown],
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 32),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
