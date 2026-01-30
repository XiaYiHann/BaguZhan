import 'package:dio/dio.dart';

import '../../network/api_client.dart';
import '../../network/api_exception.dart';
import '../models/learning_path_model.dart';
import '../models/path_category_model.dart';
import '../models/path_node_model.dart';
import '../models/question_model.dart';
import 'path_repository.dart';

/// API路径仓库实现
///
/// 通过API客户端与后端交互，获取学习路径数据
class ApiPathRepository implements PathRepository {
  ApiPathRepository({ApiClient? apiClient})
      : _client = apiClient ?? ApiClient();

  final ApiClient _client;

  @override
  Future<LearningPathModel> getLearningPath(String techStack) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/api/learning-paths/$techStack',
      );
    });

    return LearningPathModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<PathCategoryModel>> getPathCategories(String techStack) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/api/learning-paths/$techStack/categories',
      );
    });

    final data = response.data as List<dynamic>;
    return data
        .map((item) => PathCategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PathNodeModel>> getCategoryNodes(String categoryId) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/api/categories/$categoryId/nodes',
      );
    });

    final data = response.data as List<dynamic>;
    return data
        .map((item) => PathNodeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuestionModel>> getNodeQuestions(String nodeId) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/api/nodes/$nodeId/questions',
      );
    });

    final data = response.data as List<dynamic>;
    return data
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> completeNode(
    String nodeId,
    String userId,
    int correctCount,
    int totalCount,
  ) async {
    try {
      final response = await _withRetry(() {
        return _client.dio.post(
          '/api/nodes/$nodeId/complete',
          data: {
            'userId': userId,
            'correctCount': correctCount,
            'totalCount': totalCount,
          },
        );
      });

      // 根据响应判断是否成功
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>?;
        return data?['success'] as bool? ?? true;
      }
      return false;
    } on ApiException {
      rethrow;
    } catch (e) {
      return false;
    }
  }

  /// 带重试机制的请求包装器
  Future<Response<dynamic>> _withRetry(
    Future<Response<dynamic>> Function() request, {
    int retries = 1,
  }) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (_shouldRetry(error) && retries > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return _withRetry(request, retries: retries - 1);
      }
      throw _normalizeError(error);
    }
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  /// 标准化错误
  ApiException _normalizeError(DioException error) {
    final origin = error.error;
    if (origin is ApiException) {
      return origin;
    }
    return ApiException(message: '网络异常，请稍后重试');
  }
}
