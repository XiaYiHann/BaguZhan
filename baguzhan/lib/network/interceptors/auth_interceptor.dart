import 'package:dio/dio.dart';

import '../../core/device_id.dart';

/// 认证拦截器
/// 自动在每个请求中附加设备 ID 到 HTTP Header
class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 获取设备 ID 并添加到请求头
    final deviceId = await DeviceId.get();
    options.headers['X-Device-ID'] = deviceId;

    handler.next(options);
  }
}
