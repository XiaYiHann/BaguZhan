import 'package:baguzhan/data/models/option_model.dart';
import 'package:baguzhan/data/models/question_model.dart';
import 'package:baguzhan/presentation/widgets/feedback_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FeedbackPanel renders explanation and mnemonic', (tester) async {
    final question = QuestionModel(
      id: 'q1',
      content: '题目',
      topic: 'JavaScript',
      difficulty: 'easy',
      explanation: '解析内容',
      mnemonic: '助记内容',
      scenario: '场景内容',
      tags: const ['tag'],
      options: const [
        OptionModel(id: 'o1', optionText: 'A', optionOrder: 0, isCorrect: true),
        OptionModel(id: 'o2', optionText: 'B', optionOrder: 1, isCorrect: false),
        OptionModel(id: 'o3', optionText: 'C', optionOrder: 2, isCorrect: false),
        OptionModel(id: 'o4', optionText: 'D', optionOrder: 3, isCorrect: false),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedbackPanel(
            isCorrect: true,
            question: question,
            isLast: false,
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('解析'), findsOneWidget);
    expect(find.text('解析内容'), findsOneWidget);
    expect(find.text('助记口诀'), findsOneWidget);
    expect(find.text('助记内容'), findsOneWidget);
    expect(find.text('实战场景'), findsOneWidget);
    expect(find.text('场景内容'), findsOneWidget);
  });
}
