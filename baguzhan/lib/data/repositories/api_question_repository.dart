import 'package:dio/dio.dart';

import '../../network/api_client.dart';
import '../../network/api_exception.dart';
import '../models/question_model.dart';
import 'question_repository.dart';

class ApiQuestionRepository implements QuestionRepository {
  ApiQuestionRepository({ApiClient? apiClient})
      : _client = apiClient ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<QuestionModel>> getQuestions({
    String? topic,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/questions',
        queryParameters: {
          if (topic != null && topic.isNotEmpty) 'topic': topic,
          if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
    });

    final data = response.data as List<dynamic>;
    return data
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuestionModel>> getRandomQuestions({
    String? topic,
    String? difficulty,
    int? count,
  }) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/questions/random',
        queryParameters: {
          if (topic != null && topic.isNotEmpty) 'topic': topic,
          if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
          if (count != null) 'count': count,
        },
      );
    });

    final data = response.data as List<dynamic>;
    return data
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuestionModel?> getQuestionById(String id) async {
    try {
      final response = await _withRetry(() => _client.dio.get('/questions/$id'));
      return QuestionModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> _withRetry(
    Future<Response<dynamic>> Function() request, {
    int retries = 1,
  }) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (_shouldRetry(error) && retries > 0) {
        await Future.delayed(const Duration(milliseconds: 300));
        return _withRetry(request, retries: retries - 1);
      }
      throw _normalizeError(error);
    }
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  ApiException _normalizeError(DioException error) {
    final origin = error.error;
    if (origin is ApiException) {
      return origin;
    }
    return ApiException(message: '网络异常，请稍后重试');
  }
}
