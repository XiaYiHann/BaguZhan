import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/question_provider.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionProvider>();
    final total = provider.questions.length;
    final accuracyValue = (provider.accuracy * 100).clamp(0, 100).toDouble();
    final topic = provider.lastTopic ?? 'JavaScript';

    return Scaffold(
      appBar: AppBar(title: const Text('答题结果')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('统计', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatRow(
              label: '总题数',
              value: _AnimatedNumber(value: total.toDouble(), suffix: ''),
            ),
            _StatRow(
              label: '正确数',
              value: _AnimatedNumber(
                  value: provider.correctCount.toDouble(), suffix: ''),
            ),
            _StatRow(
              label: '错误数',
              value: _AnimatedNumber(
                value: provider.incorrectCount.toDouble(),
                suffix: '',
              ),
            ),
            _StatRow(
              label: '正确率',
              value: _AnimatedNumber(value: accuracyValue, suffix: '%'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/question',
                    arguments: topic,
                  );
                },
                child: const Text('重新开始'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppTheme.borderGray,
                    width: AppTheme.borderWidth,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('返回首页'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedNumber extends StatelessWidget {
  const _AnimatedNumber({required this.value, required this.suffix});

  final double value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return Text(
          '${v.round()}$suffix',
          style: Theme.of(context).textTheme.titleMedium,
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        border:
            Border.all(color: AppTheme.borderGray, width: AppTheme.borderWidth),
        boxShadow: const [AppTheme.shadowDown],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          value,
        ],
      ),
    );
  }
}
