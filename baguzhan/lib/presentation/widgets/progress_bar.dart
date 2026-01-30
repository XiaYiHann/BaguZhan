import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
    this.streak = 0,
  });

  final int currentIndex;
  final int total;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (currentIndex + 1) / total;
    final showStreakBadge = streak >= 3;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '第 ${currentIndex + 1} 题 / 共 $total 题',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: AppTheme.progressHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.borderGray,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [AppTheme.shadowDown],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: AppTheme.durationProgress,
                        curve: AppTheme.curveProgress,
                        builder: (context, value, _) {
                          final width = constraints.maxWidth * value;
                          return Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: width,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.duoGreen,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(999)),
                                  ),
                                ),
                              ),
                              if (value > 0)
                                Positioned(
                                  left: (width - AppTheme.progressHeight).clamp(
                                    0.0,
                                    constraints.maxWidth - AppTheme.progressHeight,
                                  ),
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: AppTheme.progressHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (showStreakBadge) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.streakColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [AppTheme.shadowDown],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
