import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/question_provider.dart';
import '../widgets/feedback_panel.dart';
import '../widgets/option_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/question_card.dart';
import '../widgets/status_view.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key, required this.topic});

  final String topic;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppTheme.durationPulse,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<QuestionProvider>().loadQuestions(widget.topic);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 检测是否在测试环境中
  static bool _isTestMode() {
    return bool.fromEnvironment('dart.vm.product') == false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic)),
      body: Consumer<QuestionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingStateView();
          }
          if (provider.errorMessage != null) {
            return MessageStateView(
              icon: Icons.wifi_off,
              title: '加载失败',
              subtitle: provider.errorMessage!,
              actionLabel: '重试',
              onAction: () => provider.loadQuestions(widget.topic),
            );
          }
          final question = provider.currentQuestion;
          if (question == null) {
            return const MessageStateView(
              icon: Icons.inbox,
              title: '暂无题目',
              subtitle: '换个主题试试，或者稍后再来。',
            );
          }
          final isLast = provider.currentIndex == provider.questions.length - 1;
          final optionLabels = ['A', 'B', 'C', 'D'];

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final horizontalPadding =
                  width >= 600 ? 32.0 : (width <= 360 ? 16.0 : 20.0);

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      20,
                    ),
                    children: [
                      ProgressBar(
                        currentIndex: provider.currentIndex,
                        total: provider.questions.length,
                        streak: provider.currentStreak,
                      ),
                      const SizedBox(height: 16),
                      QuestionCard(question: question),
                      const SizedBox(height: 16),
                      ...List.generate(question.options.length, (index) {
                        final option = question.options[index];
                        final selected = provider.selectedOptionIndex == index;
                        final correctIndex = question.correctAnswerIndex;
                        final isCorrect =
                            provider.isAnswered && index == correctIndex;
                        final isIncorrect = provider.isAnswered &&
                            selected &&
                            index != correctIndex;
                        return OptionCard(
                          indexLabel: optionLabels[index],
                          text: option.optionText,
                          isSelected: selected,
                          isCorrect: isCorrect,
                          isIncorrect: isIncorrect,
                          isDisabled: provider.isAnswered,
                          onTap: () => provider.selectOption(index),
                        );
                      }),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final isEnabled = provider.selectedOptionIndex != null &&
                              !provider.isAnswered;
                          final pulseValue = Curves.easeInOutSine
                              .transform(_pulseController.value);
                          return Container(
                            decoration: BoxDecoration(
                              boxShadow: isEnabled
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.duoGreen
                                            .withValues(alpha: 0.4),
                                        offset: const Offset(0, 4),
                                        blurRadius: 8 + (4 * pulseValue),
                                      ),
                                    ]
                                  : [AppTheme.shadowDown],
                              ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                key: const ValueKey('submit-answer'),
                                onPressed: provider.selectedOptionIndex == null ||
                                        provider.isAnswered
                                    ? null
                                    : provider.submitAnswer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: provider.selectedOptionIndex ==
                                          null
                                      ? AppTheme.borderGray
                                      : AppTheme.duoGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                child: Text(
                                    provider.isAnswered ? '已提交' : '提交答案'),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: AppTheme.durationPanel,
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child:
                                SlideTransition(position: slide, child: child),
                          );
                        },
                        child: provider.isAnswered
                            ? FeedbackPanel(
                                key: ValueKey('feedback-${question.id}'),
                                isCorrect: provider.lastIsCorrect ?? false,
                                question: question,
                                isLast: isLast,
                                onContinue: () {
                                  if (isLast) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/result',
                                    );
                                  } else {
                                    provider.nextQuestion();
                                  }
                                },
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('feedback-empty')),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
