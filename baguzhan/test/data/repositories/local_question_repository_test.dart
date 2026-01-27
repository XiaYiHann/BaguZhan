import 'package:baguzhan/data/datasources/local_question_datasource.dart';
import 'package:baguzhan/data/repositories/local_question_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocalQuestionRepository returns questions', () async {
    final repo = LocalQuestionRepository(LocalQuestionDatasource());
    final questions = await repo.getQuestions(topic: 'JavaScript');
    expect(questions.isNotEmpty, true);
  });

  test('LocalQuestionRepository can find by id', () async {
    final repo = LocalQuestionRepository(LocalQuestionDatasource());
    final questions = await repo.getQuestions();
    final first = questions.first;
    final found = await repo.getQuestionById(first.id);
    expect(found?.id, first.id);
  });
}
