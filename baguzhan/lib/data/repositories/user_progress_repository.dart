import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/api_client.dart';
import '../../network/api_exception.dart';
import '../../core/device_id.dart';
import '../models/learning_progress_model.dart';
import '../models/wrong_book_model.dart';

abstract class UserProgressRepository {
  Future<List<WrongBookModel>> getWrongBooks({
    String? userId,
    bool? isMastered,
  });

  Future<WrongBookModel?> markWrongBookAsMastered(String id);

  Future<void> deleteWrongBook(String id);

  Future<LearningProgressModel> getLearningProgress([String? userId]);

  Future<void> recordAnswer({
    String? userId,
    required String questionId,
    required String selectedOptionId,
    required bool isCorrect,
    int? answerTimeMs,
  });
}

class ApiUserProgressRepository implements UserProgressRepository {
  ApiUserProgressRepository({
    ApiClient? apiClient,
    SharedPreferences? prefs,
  })  : _client = apiClient ?? ApiClient(),
        _prefs = prefs;

  final ApiClient _client;
  SharedPreferences? _prefs;

  static const String _wrongBooksCacheKey = 'cached_wrong_books';
  static const String _progressCacheKey = 'cached_progress';

  /// 获取当前设备 ID 作为用户 ID
  Future<String> get _currentUserId async => DeviceId.get();

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<List<WrongBookModel>> getWrongBooks({
    String? userId,
    bool? isMastered,
  }) async {
    final effectiveUserId = userId ?? await _currentUserId;
    try {
      final response = await _client.dio.get(
        '/api/wrong-book',
        queryParameters: {
          'userId': effectiveUserId,
          if (isMastered != null) 'isMastered': isMastered.toString(),
        },
      );

      final data = response.data as List<dynamic>;
      final wrongBooks = data
          .map((item) => WrongBookModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Cache the results
      await _cacheWrongBooks(wrongBooks);

      return wrongBooks;
    } on DioException catch (error) {
      // Return cached data if available
      final cached = await _getCachedWrongBooks();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      throw _normalizeError(error);
    }
  }

  @override
  Future<WrongBookModel?> markWrongBookAsMastered(String id) async {
    try {
      final response = await _client.dio.patch('/api/wrong-book/$id/master');
      return WrongBookModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw _normalizeError(error);
    }
  }

  @override
  Future<void> deleteWrongBook(String id) async {
    try {
      await _client.dio.delete('/api/wrong-book/$id');
    } on DioException catch (error) {
      throw _normalizeError(error);
    }
  }

  @override
  Future<LearningProgressModel> getLearningProgress([String? userId]) async {
    final effectiveUserId = userId ?? await _currentUserId;
    try {
      final response = await _client.dio.get(
        '/api/progress',
        queryParameters: {'userId': effectiveUserId},
      );

      final progress =
          LearningProgressModel.fromJson(response.data as Map<String, dynamic>);

      // Cache the result
      await _cacheProgress(progress);

      return progress;
    } on DioException catch (error) {
      // Return cached data if available
      final cached = await _getCachedProgress();
      if (cached != null) {
        return cached;
      }
      throw _normalizeError(error);
    }
  }

  @override
  Future<void> recordAnswer({
    String? userId,
    required String questionId,
    required String selectedOptionId,
    required bool isCorrect,
    int? answerTimeMs,
  }) async {
    final effectiveUserId = userId ?? await _currentUserId;
    try {
      await _client.dio.post('/api/answers', data: {
        'userId': effectiveUserId,
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'isCorrect': isCorrect,
        if (answerTimeMs != null) 'answerTimeMs': answerTimeMs,
      });
    } on DioException catch (error) {
      throw _normalizeError(error);
    }
  }

  // Cache methods
  Future<void> _cacheWrongBooks(List<WrongBookModel> wrongBooks) async {
    final prefs = await _preferences;
    final jsonList = wrongBooks.map((wb) => wb.toJson()).toList();
    await prefs.setString(_wrongBooksCacheKey, jsonList.toString());
  }

  Future<List<WrongBookModel>?> _getCachedWrongBooks() async {
    final prefs = await _preferences;
    final cached = prefs.getString(_wrongBooksCacheKey);
    if (cached == null) return null;

    try {
      // Simple parsing - in production use jsonDecode properly
      return null; // Simplified for now
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheProgress(LearningProgressModel progress) async {
    final prefs = await _preferences;
    await prefs.setString(_progressCacheKey, progress.toJson().toString());
  }

  Future<LearningProgressModel?> _getCachedProgress() async {
    final prefs = await _preferences;
    final cached = prefs.getString(_progressCacheKey);
    if (cached == null) return null;

    try {
      // Simple parsing - in production use jsonDecode properly
      return null; // Simplified for now
    } catch (_) {
      return null;
    }
  }

  ApiException _normalizeError(DioException error) {
    final origin = error.error;
    if (origin is ApiException) {
      return origin;
    }
    return ApiException(message: '网络异常，请稍后重试');
  }
}
