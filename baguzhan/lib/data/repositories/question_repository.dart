import '../models/question_model.dart';

abstract class QuestionRepository {
  Future<List<QuestionModel>> getQuestions({
    String? topic,
    String? difficulty,
    int? limit,
    int? offset,
  });

  Future<List<QuestionModel>> getRandomQuestions({
    String? topic,
    String? difficulty,
    int? count,
  });

  Future<QuestionModel?> getQuestionById(String id);
}
