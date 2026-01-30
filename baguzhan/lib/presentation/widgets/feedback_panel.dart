import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/question_model.dart';
import 'action_buttons.dart';
import 'duo_card.dart';

class FeedbackPanel extends StatefulWidget {
  const FeedbackPanel({
    super.key,
    required this.isCorrect,
    required this.question,
    required this.onContinue,
    required this.isLast,
  });

  final bool isCorrect;
  final QuestionModel question;
  final VoidCallback onContinue;
  final bool isLast;

  @override
  State<FeedbackPanel> createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends State<FeedbackPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _emojiController;

  @override
  void initState() {
    super.initState();
    _emojiController = AnimationController(
      vsync: this,
      duration: AppTheme.durationElastic,
    )..forward();
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  Color get _background => widget.isCorrect
      ? AppTheme.correctBackground
      : AppTheme.incorrectBackground;
  Color get _textColor =>
      widget.isCorrect ? AppTheme.duoGreen : AppTheme.duoRed;

  @override
  Widget build(BuildContext context) {
    final maxPanelHeight =
        (MediaQuery.sizeOf(context).height * 0.45).clamp(240.0, 420.0);

    return DuoCard(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: _background,
      radius: AppTheme.radiusPanel,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxPanelHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isCorrect ? '回答正确！' : '回答错误',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: _textColor),
                  ),
                ),
                AnimatedScale(
                  scale: _emojiController.value,
                  duration: AppTheme.durationElastic,
                  curve: AppTheme.curveElastic,
                  child: Text(
                    widget.isCorrect ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!widget.isCorrect)
              Text(
                '正确答案：${widget.question.options[widget.question.correctAnswerIndex].optionText}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.question.explanation != null)
                      _Section(title: '解析', content: widget.question.explanation!),
                    if (widget.question.mnemonic != null)
                      _Section(title: '助记口诀', content: widget.question.mnemonic!),
                    if (widget.question.scenario != null)
                      _Section(title: '实战场景', content: widget.question.scenario!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ActionButtons(
              primaryKey: const ValueKey('continue-button'),
              primaryLabel: widget.isLast ? '查看结果' : '下一题',
              onPrimaryPressed: widget.onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
