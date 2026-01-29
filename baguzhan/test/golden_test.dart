import 'package:baguzhan/core/theme/app_theme.dart';
import 'package:baguzhan/data/models/option_model.dart';
import 'package:baguzhan/data/models/question_model.dart';
import 'package:baguzhan/presentation/widgets/feedback_panel.dart';
import 'package:baguzhan/presentation/widgets/option_card.dart';
import 'package:baguzhan/presentation/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpGolden(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

QuestionModel _fakeQuestion({
  String? explanation,
  String? mnemonic,
  String? scenario,
}) {
  return QuestionModel(
    id: 'q1',
    content: '题目',
    topic: 'JavaScript',
    difficulty: 'easy',
    explanation: explanation,
    mnemonic: mnemonic,
    scenario: scenario,
    tags: const ['tag'],
    options: const [
      OptionModel(id: 'o1', optionText: 'A', optionOrder: 0, isCorrect: true),
      OptionModel(id: 'o2', optionText: 'B', optionOrder: 1, isCorrect: false),
      OptionModel(id: 'o3', optionText: 'C', optionOrder: 2, isCorrect: false),
      OptionModel(id: 'o4', optionText: 'D', optionOrder: 3, isCorrect: false),
    ],
  );
}

void main() {
  testWidgets('golden - OptionCard states', (tester) async {
    await _pumpGolden(
      tester,
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OptionCard(
              indexLabel: 'A',
              text: 'Normal',
              isSelected: false,
              isCorrect: false,
              isIncorrect: false,
              isDisabled: false,
              onTap: () {},
            ),
            OptionCard(
              indexLabel: 'B',
              text: 'Selected',
              isSelected: true,
              isCorrect: false,
              isIncorrect: false,
              isDisabled: false,
              onTap: () {},
            ),
            OptionCard(
              indexLabel: 'C',
              text: 'Correct',
              isSelected: false,
              isCorrect: true,
              isIncorrect: false,
              isDisabled: true,
              onTap: () {},
            ),
            OptionCard(
              indexLabel: 'D',
              text: 'Incorrect',
              isSelected: true,
              isCorrect: false,
              isIncorrect: true,
              isDisabled: true,
              onTap: () {},
            ),
          ],
        ),
      ),
      size: const Size(390, 520),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/option_card_states.png'),
    );
  });

  testWidgets('golden - ProgressBar', (tester) async {
    await _pumpGolden(
      tester,
      const Padding(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          width: 320,
          child: ProgressBar(currentIndex: 2, total: 10),
        ),
      ),
      size: const Size(390, 220),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/progress_bar.png'),
    );
  });

  testWidgets('golden - FeedbackPanel (scrollable)', (tester) async {
    final question = _fakeQuestion(
      explanation: '解析内容\n' * 12,
      mnemonic: '助记内容\n' * 6,
      scenario: '场景内容\n' * 8,
    );

    await _pumpGolden(
      tester,
      Padding(
        padding: const EdgeInsets.all(20),
        child: FeedbackPanel(
          isCorrect: false,
          question: question,
          isLast: false,
          onContinue: () {},
        ),
      ),
      size: const Size(390, 700),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/feedback_panel.png'),
    );
  });
}
