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
        '/api/paths/tech/$techStack',
      );
    });

    final data = response.data as Map<String, dynamic>;
    return _parseLearningPathResponse(data);
  }

  @override
  Future<List<PathCategoryModel>> getPathCategories(String techStack) async {
    // 先获取路径，再获取分类
    final response = await _withRetry(() {
      return _client.dio.get(
        '/api/paths/tech/$techStack',
      );
    });

    final data = response.data as Map<String, dynamic>;
    final categories = data['categories'] as List<dynamic>? ?? [];
    return categories
        .map((item) => _parseCategoryFromApi(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PathNodeModel>> getCategoryNodes(String categoryId) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/api/paths/categories/$categoryId/nodes',
      );
    });

    final data = response.data as Map<String, dynamic>;
    final nodes = data['nodes'] as List<dynamic>? ?? [];
    return nodes
        .map((item) => _parseNodeFromApi(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuestionModel>> getNodeQuestions(String nodeId) async {
    final response = await _withRetry(() {
      return _client.dio.get(
        '/api/questions',
        queryParameters: {'nodeId': nodeId},
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
          '/api/paths/nodes/$nodeId/complete',
          data: {
            'correctCount': correctCount,
            'totalCount': totalCount,
          },
          options: Options(
            headers: {'X-Device-ID': userId},
          ),
        );
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>?;
        return data?['node'] != null;
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

  // ============ API 响应解析方法 ============

  /// 解析学习路径响应
  LearningPathModel _parseLearningPathResponse(Map<String, dynamic> data) {
    final pathData = data['path'] as Map<String, dynamic>? ?? data;
    final categories = data['categories'] as List<dynamic>? ?? [];
    final progress = data['progress'] as Map<String, dynamic>?;

    // 计算总节点数和已完成节点数
    int totalNodes = 0;
    int completedNodes = 0;
    final parsedCategories = <PathCategoryModel>[];

    for (final cat in categories) {
      final catMap = cat as Map<String, dynamic>;
      final parsedCat = _parseCategoryFromApi(catMap);
      parsedCategories.add(parsedCat);
      totalNodes += parsedCat.totalNodes;
      completedNodes += parsedCat.completedNodes;
    }

    // 如果有进度数据，使用进度数据
    if (progress != null) {
      totalNodes = progress['totalNodes'] as int? ?? totalNodes;
      completedNodes = progress['completedNodes'] as int? ?? completedNodes;
    }

    return LearningPathModel(
      id: pathData['id'] as String? ?? '',
      techStack: pathData['techStack'] as String? ?? '',
      title: pathData['title'] as String? ?? '',
      subtitle: pathData['subtitle'] as String? ?? '',
      characterIcon: pathData['characterIcon'] as String? ?? '🗡️',
      characterDialog: pathData['characterDialog'] as String? ?? '',
      categories: parsedCategories,
      totalNodes: totalNodes,
      completedNodes: completedNodes,
    );
  }

  /// 解析分类数据
  PathCategoryModel _parseCategoryFromApi(Map<String, dynamic> data) {
    final nodes = data['nodes'] as List<dynamic>? ?? [];

    int totalNodes = nodes.length;
    int completedNodes = 0;

    final parsedNodes = nodes.map((node) {
      final parsed = _parseNodeFromApi(node as Map<String, dynamic>);
      if (parsed.status == NodeStatus.completed) {
        completedNodes++;
      }
      return parsed;
    }).toList();

    return PathCategoryModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? '',
      color: data['color'] as String? ?? '#58CC02',
      order: data['sortOrder'] as int? ?? data['order'] as int? ?? 0,
      totalNodes: totalNodes,
      completedNodes: completedNodes,
      nodes: parsedNodes,
    );
  }

  /// 解析节点数据
  PathNodeModel _parseNodeFromApi(Map<String, dynamic> data) {
    return PathNodeModel(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      icon: data['icon'] as String? ?? '',
      color: data['color'] as String? ?? 'primary',
      order: data['sortOrder'] as int? ?? data['order'] as int? ?? 0,
      status: _parseNodeStatus(data['status'] as String?),
      questionIds: _parseQuestionIds(data['questionIds']),
      prerequisiteNodeId: data['prerequisiteNodeId'] as String?,
      estimatedMinutes: data['estimatedMinutes'] as int? ?? 10,
    );
  }

  /// 解析节点状态
  NodeStatus _parseNodeStatus(String? status) {
    switch (status) {
      case 'unlocked':
        return NodeStatus.unlocked;
      case 'completed':
        return NodeStatus.completed;
      case 'current':
        // current 视为 unlocked
        return NodeStatus.unlocked;
      case 'locked':
      default:
        return NodeStatus.locked;
    }
  }

  /// 解析题目 ID 列表
  List<String> _parseQuestionIds(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.cast<String>();
    }
    return [];
  }
}
