import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'duo_card.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.completedCount,
    required this.totalCount,
    this.difficulty,
    this.onTap,
  });

  final String topic;
  final int completedCount;
  final int totalCount;
  final String? difficulty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final topicColor = AppTheme.topicColors[topic] ?? AppTheme.duoBlue;

    return GestureDetector(
      onTap: onTap,
      child: DuoCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: topicColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      topic,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                if (difficulty != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(difficulty!).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      difficulty!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _getDifficultyColor(difficulty!),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          Text(
                            '$completedCount/$totalCount',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: AppTheme.miniProgressHeight,
                          color: AppTheme.borderGray,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                color: AppTheme.duoGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.borderGray,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case '简单':
      case 'easy':
        return AppTheme.difficultyEasy;
      case '中等':
      case 'medium':
        return AppTheme.difficultyMedium;
      case '困难':
      case 'hard':
        return AppTheme.difficultyHard;
      default:
        return AppTheme.difficultyMedium;
    }
  }
}
