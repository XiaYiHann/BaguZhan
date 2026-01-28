import 'package:dio/dio.dart';

import '../api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final message = _resolveMessage(err, statusCode);
    final wrapped = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ApiException(message: message, statusCode: statusCode),
    );
    handler.next(wrapped);
  }

  String _resolveMessage(DioException err, int? statusCode) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return '网络超时，请稍后重试';
      case DioExceptionType.badResponse:
        if (statusCode == 400) {
          return '请求参数有误';
        }
        if (statusCode == 404) {
          return '资源不存在';
        }
        if (statusCode != null && statusCode >= 500) {
          return '服务器暂时不可用';
        }
        return '请求失败，请稍后重试';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return '网络异常，请检查连接';
    }
  }
}
