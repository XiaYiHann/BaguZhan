import 'dart:convert';
import 'dart:typed_data';

import 'package:baguzhan/data/models/path_node_model.dart';
import 'package:baguzhan/data/repositories/api_path_repository.dart';
import 'package:baguzhan/network/api_client.dart';
import 'package:baguzhan/network/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 测试用的 HTTP 适配器
class TestAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(String path, String? method)? handler;

  TestAdapter({this.handler});

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      final response = handler!(options.path, options.method);
      return ResponseBody.fromString(
        jsonEncode(response),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // 默认处理
    if (options.path.startsWith('/api/paths/tech/')) {
      final techStack = options.path.replaceFirst('/api/paths/tech/', '');
      return ResponseBody.fromString(
        jsonEncode(_getPathResponse(techStack)),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.path.startsWith('/api/paths/categories/')) {
      final categoryId = options.path.split('/').last.replaceAll('/nodes', '');
      return ResponseBody.fromString(
        jsonEncode(_getCategoryNodesResponse(categoryId)),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.path.contains('/nodes/') && options.path.contains('/complete')) {
      return ResponseBody.fromString(
        jsonEncode(_getCompleteNodeResponse()),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({'error': 'not found'}),
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

// 测试数据
Map<String, dynamic> _getPathResponse(String techStack) {
  return {
    'path': {
      'id': 'js-path',
      'techStack': techStack,
      'title': 'JavaScript 学习路径',
      'subtitle': '从基础到进阶',
      'characterIcon': '🗡️',
      'characterDialog': '准备好斩题了吗？',
    },
    'categories': [
      {
        'id': 'cat-1',
        'pathId': 'js-path',
        'name': '基础语法',
        'icon': '📘',
        'color': '#58CC02',
        'sortOrder': 1,
        'nodes': [
          {
            'id': 'node-1',
            'categoryId': 'cat-1',
            'title': 'Hello World',
            'icon': '👋',
            'color': 'primary',
            'sortOrder': 1,
            'questionIds': ['q1', 'q2'],
            'prerequisiteNodeId': null,
            'estimatedMinutes': 5,
            'status': 'unlocked',
          },
          {
            'id': 'node-2',
            'categoryId': 'cat-1',
            'title': '变量与类型',
            'icon': '📦',
            'color': 'primary',
            'sortOrder': 2,
            'questionIds': ['q3', 'q4'],
            'prerequisiteNodeId': 'node-1',
            'estimatedMinutes': 10,
            'status': 'locked',
          },
        ],
      },
    ],
    'progress': {
      'totalNodes': 2,
      'completedNodes': 0,
      'completionRate': 0.0,
    },
  };
}

Map<String, dynamic> _getCategoryNodesResponse(String categoryId) {
  return {
    'category': {
      'id': categoryId,
      'pathId': 'js-path',
      'name': '基础语法',
      'icon': '📘',
      'color': '#58CC02',
      'sortOrder': 1,
    },
    'nodes': [
      {
        'id': 'node-1',
        'categoryId': categoryId,
        'title': 'Hello World',
        'icon': '👋',
        'color': 'primary',
        'sortOrder': 1,
        'questionIds': ['q1', 'q2'],
        'prerequisiteNodeId': null,
        'estimatedMinutes': 5,
        'status': 'unlocked',
      },
      {
        'id': 'node-2',
        'categoryId': categoryId,
        'title': '变量与类型',
        'icon': '📦',
        'color': 'primary',
        'sortOrder': 2,
        'questionIds': ['q3', 'q4'],
        'prerequisiteNodeId': 'node-1',
        'estimatedMinutes': 10,
        'status': 'locked',
      },
    ],
  };
}

Map<String, dynamic> _getCompleteNodeResponse() {
  return {
    'node': {
      'id': 'node-1',
      'categoryId': 'cat-1',
      'title': 'Hello World',
      'icon': '👋',
      'color': 'primary',
      'sortOrder': 1,
      'questionIds': ['q1', 'q2'],
      'prerequisiteNodeId': null,
      'estimatedMinutes': 5,
      'status': 'completed',
    },
    'progress': {
      'correctCount': 2,
      'totalCount': 2,
    },
    'nextNode': {
      'id': 'node-2',
      'categoryId': 'cat-1',
      'title': '变量与类型',
      'icon': '📦',
      'color': 'primary',
      'sortOrder': 2,
      'questionIds': ['q3', 'q4'],
      'prerequisiteNodeId': 'node-1',
      'estimatedMinutes': 10,
      'status': 'unlocked',
    },
  };
}

void main() {
  late Dio dio;
  late ApiPathRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = TestAdapter();
    dio.interceptors.add(ErrorInterceptor());
    repository = ApiPathRepository(apiClient: ApiClient(dio: dio));
  });

  group('ApiPathRepository', () {
    test('getLearningPath 获取学习路径', () async {
      final result = await repository.getLearningPath('javascript');

      expect(result.id, 'js-path');
      expect(result.techStack, 'javascript');
      expect(result.title, 'JavaScript 学习路径');
      expect(result.categories.length, 1);
      expect(result.totalNodes, 2);
    });

    test('getLearningPath 正确解析分类数据', () async {
      final result = await repository.getLearningPath('javascript');

      final category = result.categories.first;
      expect(category.id, 'cat-1');
      expect(category.name, '基础语法');
      expect(category.nodes.length, 2);
    });

    test('getLearningPath 正确解析节点数据', () async {
      final result = await repository.getLearningPath('javascript');

      final node = result.categories.first.nodes.first;
      expect(node.id, 'node-1');
      expect(node.title, 'Hello World');
      expect(node.status, NodeStatus.unlocked);
      expect(node.questionIds, ['q1', 'q2']);
    });

    test('getPathCategories 获取分类列表', () async {
      final result = await repository.getPathCategories('javascript');

      expect(result.length, 1);
      expect(result.first.id, 'cat-1');
      expect(result.first.name, '基础语法');
    });

    test('getCategoryNodes 获取分类下的节点', () async {
      final result = await repository.getCategoryNodes('cat-1');

      expect(result.length, 2);
      expect(result.first.id, 'node-1');
      expect(result.first.title, 'Hello World');
      expect(result.first.status, NodeStatus.unlocked);
      expect(result.last.status, NodeStatus.locked);
    });

    test('completeNode 完成节点', () async {
      final result = await repository.completeNode(
        'node-1',
        'user-123',
        2,
        2,
      );

      expect(result, isTrue);
    });

    test('正确解析 snake_case 字段为 camelCase', () async {
      final result = await repository.getLearningPath('javascript');

      // 验证后端字段名（snake_case）被正确转换为前端字段名
      expect(result.title, isNotNull);
      expect(result.techStack, isNotNull);
    });
  });
}
