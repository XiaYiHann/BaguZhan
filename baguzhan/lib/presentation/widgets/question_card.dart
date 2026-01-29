import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/question_model.dart';
import 'duo_card.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
  });

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(text: question.topic, background: AppTheme.duoBlue),
              const SizedBox(width: 8),
              _Chip(
                text: question.difficulty.toUpperCase(),
                background: AppTheme.duoGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.content,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: question.tags
                .map((tag) => _Chip(text: tag, background: AppTheme.borderGray))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.background,
  });

  final String text;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final onColor =
        background == AppTheme.borderGray ? AppTheme.textPrimary : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: onColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
