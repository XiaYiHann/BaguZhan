/// Neo-Brutal 风格统计指标栏组件
library;

import 'package:flutter/material.dart';

import '../../../core/theme/neo_brutal_theme.dart';

/// 统计指标数据
class StatMetric {
  const StatMetric({
    required this.icon,
    required this.value,
    required this.color,
    this.suffix = '',
  });

  final IconData icon;
  final String value;
  final Color color;
  final String suffix;
}

/// Neo-Brutal 顶部统计栏
///
/// 横向展示 4 个核心统计指标：连续天数、正确率、总题数、积分
/// 每个统计项都是独立的白色卡片，带边框和阴影
class NeoStatBar extends StatelessWidget {
  const NeoStatBar({
    super.key,
    required this.metrics,
    this.padding = const EdgeInsets.symmetric(
      horizontal: NeoBrutalTheme.spaceMd,
      vertical: NeoBrutalTheme.spaceXs,
    ),
  });

  factory NeoStatBar.standard({
    int streak = 0,
    double accuracy = 0.0,
    int totalQuestions = 0,
    int xp = 0,
  }) {
    return NeoStatBar(
      metrics: [
        StatMetric(
          icon: Icons.local_fire_department,
          value: '$streak',
          color: NeoBrutalTheme.fire,
          suffix: '天',
        ),
        StatMetric(
          icon: Icons.check_circle,
          value: '${(accuracy * 100).toInt()}',
          color: NeoBrutalTheme.primary,
          suffix: '%',
        ),
        StatMetric(
          icon: Icons.quiz,
          value: totalQuestions.toString(),
          color: NeoBrutalTheme.secondary,
          suffix: '题',
        ),
        StatMetric(
          icon: Icons.diamond,
          value: xp >= 1000 ? '${(xp / 1000).toStringAsFixed(1)}k' : '$xp',
          color: NeoBrutalTheme.diamond,
        ),
      ],
    );
  }

  final List<StatMetric> metrics;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: NeoBrutalTheme.background,
      child: Row(
        children: metrics.map((metric) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _MetricCard(
                icon: metric.icon,
                value: metric.value,
                suffix: metric.suffix,
                color: metric.color,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 统计卡片 - 白色背景+边框+阴影
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.suffix,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: NeoBrutalTheme.charcoal,
          width: NeoBrutalTheme.borderWidth,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: NeoBrutalTheme.shadowSm,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            suffix.isEmpty ? value : '$value$suffix',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NeoBrutalTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

/// 迷你顶部统计栏（用于导航栏）
class NeoMiniStatBar extends StatelessWidget {
  const NeoMiniStatBar({
    super.key,
    this.streak = 0,
    this.gems = 0,
    this.hearts = 5,
  });

  final int streak;
  final int gems;
  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStat(
          icon: Icons.local_fire_department,
          value: streak.toString(),
          color: NeoBrutalTheme.fire,
        ),
        const SizedBox(width: 16),
        _buildStat(
          icon: Icons.diamond,
          value: gems.toString(),
          color: NeoBrutalTheme.diamond,
        ),
        const SizedBox(width: 16),
        _buildStat(
          icon: Icons.favorite,
          value: hearts.toString(),
          color: NeoBrutalTheme.error,
        ),
      ],
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: NeoBrutalTheme.styleHeadlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
