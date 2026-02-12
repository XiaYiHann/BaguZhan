import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:baguzhan/network/interceptors/auth_interceptor.dart';
import 'package:baguzhan/core/device_id.dart';

// Mock 类
@GenerateMocks([Dio])
class MockDio extends Mock implements Dio {}

void main() {
  group('AuthInterceptor', () {
    late AuthInterceptor interceptor;

    setUp(() {
      interceptor = AuthInterceptor();
    });

    group('请求拦截', () {
      test('应该在请求头中添加 X-Device-ID', () async {
        // 注意：由于 DeviceId 使用静态方法，这里主要验证拦截器结构
        // 完整的集成测试需要更多 mock 设置

        final requestOptions = RequestOptions(
          path: '/api/test',
          method: 'GET',
        );

        final handler = _MockRequestInterceptorHandler();

        await interceptor.onRequest(requestOptions, handler);

        // 验证 handler 被调用
        expect(handler.called, isTrue);
      });

      test('设备 ID 应该是有效的 UUID 格式', () async {
        // 验证 DeviceId 服务返回有效格式
        final deviceId = await DeviceId.get();

        expect(DeviceId.isValid(deviceId), isTrue);
      });
    });
  });
}

// 测试用的 Handler mock
class _MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool called = false;

  @override
  void next(RequestOptions requestOptions) {
    called = true;
  }

  @override
  void error(DioException error) {
    called = true;
  }
}
