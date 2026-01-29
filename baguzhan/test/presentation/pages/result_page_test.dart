import 'package:baguzhan/data/models/option_model.dart';
import 'package:baguzhan/data/models/question_model.dart';
import 'package:baguzhan/data/repositories/question_repository.dart';
import 'package:baguzhan/presentation/pages/result_page.dart';
import 'package:baguzhan/presentation/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeQuestionProvider extends QuestionProvider {
  FakeQuestionProvider() : super(_FakeRepo()) {
    questions = [
      const QuestionModel(
        id: 'q1',
        content: '题目',
        topic: 'JavaScript',
        difficulty: 'easy',
        explanation: null,
        mnemonic: null,
        scenario: null,
        tags: [],
        options: [
          OptionModel(
              id: 'o1', optionText: 'A', optionOrder: 0, isCorrect: true),
          OptionModel(
              id: 'o2', optionText: 'B', optionOrder: 1, isCorrect: false),
          OptionModel(
              id: 'o3', optionText: 'C', optionOrder: 2, isCorrect: false),
          OptionModel(
              id: 'o4', optionText: 'D', optionOrder: 3, isCorrect: false),
        ],
      ),
    ];
    correctCount = 1;
    incorrectCount = 0;
  }
}

class _FakeRepo implements QuestionRepository {
  @override
  Future<QuestionModel?> getQuestionById(String id) async => null;

  @override
  Future<List<QuestionModel>> getQuestions({
    String? topic,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<List<QuestionModel>> getRandomQuestions({
    String? topic,
    String? difficulty,
    int? count,
  }) async {
    return [];
  }
}

void main() {
  testWidgets('ResultPage shows stats', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<QuestionProvider>(
        create: (_) => FakeQuestionProvider(),
        child: const MaterialApp(home: ResultPage()),
      ),
    );

    expect(find.text('总题数'), findsOneWidget);
    expect(find.text('正确数'), findsOneWidget);
    expect(find.text('错误数'), findsOneWidget);
    expect(find.text('正确率'), findsOneWidget);
  });
}
