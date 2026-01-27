import 'package:baguzhan/data/models/option_model.dart';
import 'package:baguzhan/data/models/question_model.dart';
import 'package:baguzhan/data/repositories/question_repository.dart';
import 'package:baguzhan/presentation/providers/question_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeQuestionRepository implements QuestionRepository {
  @override
  Future<QuestionModel?> getQuestionById(String id) async => _questions.first;

  @override
  Future<List<QuestionModel>> getQuestions({String? topic, int? limit}) async => _questions;
}

final _questions = [
  QuestionModel(
    id: 'q1',
    content: '题目',
    topic: 'JavaScript',
    difficulty: 'easy',
    explanation: '解析',
    mnemonic: '口诀',
    scenario: '场景',
    tags: const ['tag'],
    options: const [
      OptionModel(id: 'o1', optionText: 'A', optionOrder: 0, isCorrect: false),
      OptionModel(id: 'o2', optionText: 'B', optionOrder: 1, isCorrect: true),
      OptionModel(id: 'o3', optionText: 'C', optionOrder: 2, isCorrect: false),
      OptionModel(id: 'o4', optionText: 'D', optionOrder: 3, isCorrect: false),
    ],
  ),
];

void main() {
  test('QuestionProvider loadQuestions fills data', () async {
    final provider = QuestionProvider(FakeQuestionRepository());
    await provider.loadQuestions('JavaScript');
    expect(provider.questions.length, 1);
    expect(provider.isLoading, false);
  });

  test('QuestionProvider submitAnswer updates stats', () async {
    final provider = QuestionProvider(FakeQuestionRepository());
    await provider.loadQuestions('JavaScript');
    provider.selectOption(1);
    provider.submitAnswer();
    expect(provider.isAnswered, true);
    expect(provider.correctCount, 1);
    expect(provider.incorrectCount, 0);
  });
}
