import 'package:baguzhan/data/models/option_model.dart';
import 'package:baguzhan/data/models/question_model.dart';
import 'package:baguzhan/presentation/widgets/question_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('QuestionCard renders content and tags', (tester) async {
    const question = QuestionModel(
      id: 'q1',
      content: '问题内容',
      topic: 'JavaScript',
      difficulty: 'easy',
      explanation: null,
      mnemonic: null,
      scenario: null,
      tags: ['event-loop', 'async'],
      options: [
        OptionModel(id: 'o1', optionText: 'A', optionOrder: 0, isCorrect: true),
        OptionModel(
            id: 'o2', optionText: 'B', optionOrder: 1, isCorrect: false),
        OptionModel(
            id: 'o3', optionText: 'C', optionOrder: 2, isCorrect: false),
        OptionModel(
            id: 'o4', optionText: 'D', optionOrder: 3, isCorrect: false),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: QuestionCard(question: question)),
      ),
    );

    expect(find.text('问题内容'), findsOneWidget);
    expect(find.text('event-loop'), findsOneWidget);
    expect(find.text('async'), findsOneWidget);
  });
}
