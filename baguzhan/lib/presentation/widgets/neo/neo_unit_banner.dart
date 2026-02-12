/// Neo-Brutal 风格单元横幅组件
library;

import 'package:flutter/material.dart';

import '../../../core/theme/neo_brutal_theme.dart';
import 'neo_container.dart';

/// Neo-Brutal 学习单元横幅
///
/// 显示当前学习单元信息，绿色高亮背景
class NeoUnitBanner extends StatelessWidget {
  const NeoUnitBanner({
    super.key,
    required this.unit,
    required this.part,
    required this.topic,
    this.subtitle,
    this.onTap,
    this.padding,
  });

  final int unit;
  final int part;
  final String topic;
  final String? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return NeoContainer(
      color: NeoBrutalTheme.primary,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMd,
            vertical: NeoBrutalTheme.spaceSm,
          ),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签
          Text(
            'CURRENT MISSION',
            style: NeoBrutalTheme.styleLabel.copyWith(
              color: NeoBrutalTheme.charcoal.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          // 单元信息
          Text(
            'Unit $unit, Part $unit: $topic',
            style: NeoBrutalTheme.styleHeadlineSmall.copyWith(
              color: NeoBrutalTheme.charcoal, // 黑色而非白色
              fontSize: 18,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: NeoBrutalTheme.styleBodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 迷你单元横幅（更紧凑的版本）
class NeoMiniUnitBanner extends StatelessWidget {
  const NeoMiniUnitBanner({
    super.key,
    required this.unit,
    required this.topic,
    this.progress = 0.0,
    this.onTap,
  });

  final int unit;
  final String topic;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeoContainer(
      color: NeoBrutalTheme.primary,
      padding: const EdgeInsets.all(NeoBrutalTheme.spaceMd),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNIT $unit',
                  style: NeoBrutalTheme.styleLabel.copyWith(
                    color: NeoBrutalTheme.charcoal.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: NeoBrutalTheme.styleHeadlineSmall.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // 进度指示器
          if (progress > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusXxs),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: NeoBrutalTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
