import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'interceptors/error_interceptor.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  Dio get dio => _dio;

  static Dio _createDio() {
    const baseUrl = String.fromEnvironment(
      'BFF_BASE_URL',
      defaultValue: 'http://localhost:3000',
    );

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

    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }
}
