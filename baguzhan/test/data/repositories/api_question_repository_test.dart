import 'dart:convert';
import 'dart:typed_data';

import 'package:baguzhan/data/repositories/api_question_repository.dart';
import 'package:baguzhan/network/api_client.dart';
import 'package:baguzhan/network/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/questions') {
      final body = jsonEncode(_questions);
      return ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.path == '/questions/random') {
      final body = jsonEncode([_questions.first]);
      return ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.path.startsWith('/questions/')) {
      final id = options.path.replaceFirst('/questions/', '');
      final found = _questions.where((question) => question['id'] == id).toList();
      if (found.isEmpty) {
        return ResponseBody.fromString(
          jsonEncode({'error': 'not found'}),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode(found.first),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString('', 500);
  }
}

final _questions = [
  {
    'id': 'q1',
    'content': '题目',
    'topic': 'JavaScript',
    'difficulty': 'easy',
    'explanation': '解析',
    'mnemonic': '口诀',
    'scenario': '场景',
    'tags': ['tag'],
    'options': [
      {'id': 'o1', 'optionText': 'A', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'o2', 'optionText': 'B', 'optionOrder': 1, 'isCorrect': true},
      {'id': 'o3', 'optionText': 'C', 'optionOrder': 2, 'isCorrect': false},
      {'id': 'o4', 'optionText': 'D', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
];

void main() {
  late Dio dio;
  late ApiQuestionRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = TestAdapter();
    dio.interceptors.add(ErrorInterceptor());
    repository = ApiQuestionRepository(apiClient: ApiClient(dio: dio));
  });

  test('ApiQuestionRepository 获取题目列表', () async {
    final result = await repository.getQuestions(topic: 'JavaScript');
    expect(result.length, 1);
    expect(result.first.id, 'q1');
  });

  test('ApiQuestionRepository 获取随机题目', () async {
    final result = await repository.getRandomQuestions(topic: 'JavaScript', count: 1);
    expect(result.length, 1);
  });

  test('ApiQuestionRepository 404 返回 null', () async {
    final result = await repository.getQuestionById('missing');
    expect(result, isNull);
  });

}
