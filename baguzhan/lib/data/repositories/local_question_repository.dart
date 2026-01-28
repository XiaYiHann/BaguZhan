import 'dart:math';

import '../datasources/local_question_datasource.dart';
import '../models/question_model.dart';
import 'question_repository.dart';

class LocalQuestionRepository implements QuestionRepository {
  LocalQuestionRepository(this.datasource);

  final LocalQuestionDatasource datasource;

  @override
  Future<QuestionModel?> getQuestionById(String id) async {
    final questions = datasource.getAllQuestions();
    try {
      return questions.firstWhere((question) => question.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<QuestionModel>> getQuestions({
    String? topic,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    final allQuestions = datasource.getAllQuestions();
    var filtered = allQuestions;

    if (topic != null && topic.isNotEmpty) {
      filtered = filtered.where((question) => question.topic == topic).toList();
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      filtered = filtered.where((question) => question.difficulty == difficulty).toList();
    }

    if (offset != null && offset > 0) {
      filtered = filtered.skip(offset).toList();
    }

    if (limit != null && limit > 0 && filtered.length > limit) {
      return filtered.take(limit).toList();
    }

    return filtered;
  }

  @override
  Future<List<QuestionModel>> getRandomQuestions({
    String? topic,
    String? difficulty,
    int? count,
  }) async {
    final filtered = await getQuestions(
      topic: topic,
      difficulty: difficulty,
    );

    if (filtered.isEmpty) {
      return [];
    }

    final copy = [...filtered];
    copy.shuffle(Random());

    if (count != null && count > 0 && copy.length > count) {
      return copy.take(count).toList();
    }

    return copy;
  }
}
