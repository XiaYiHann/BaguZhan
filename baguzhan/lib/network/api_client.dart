import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'interceptors/error_interceptor.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  Dio get dio => _dio;

  static Dio _createDio() {
    const definedBaseUrl = String.fromEnvironment('BFF_BASE_URL');
    final baseUrl = definedBaseUrl.isNotEmpty
        ? definedBaseUrl
        : switch (defaultTargetPlatform) {
            TargetPlatform.android => 'http://10.0.2.2:37123',
            _ => 'http://localhost:37123',
          };

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }

    // 认证拦截器 - 必须在错误拦截器之前添加
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }
}
