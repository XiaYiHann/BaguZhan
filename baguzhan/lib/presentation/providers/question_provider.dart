import 'package:flutter/foundation.dart';

import '../../data/models/question_model.dart';
import '../../data/models/user_answer_model.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/repositories/user_progress_repository.dart';
import '../../network/api_exception.dart';

enum QuestionState { initial, loading, loaded, error }

class QuestionProvider extends ChangeNotifier {
  QuestionProvider(
    this.repository, {
    UserProgressRepository? userProgressRepository,
  }) : _userProgressRepository = userProgressRepository;

  final QuestionRepository repository;
  final UserProgressRepository? _userProgressRepository;

  QuestionState _state = QuestionState.initial;
  String? _errorMessage;
  List<QuestionModel> questions = [];
  int currentIndex = 0;
  int? selectedOptionIndex;
  bool isAnswered = false;
  bool isCompleted = false;
  bool? lastIsCorrect;
  int correctCount = 0;
  int incorrectCount = 0;
  String? lastTopic;
  final List<UserAnswerModel> answers = [];
  DateTime? _questionStartTime;
  String? _userId;

  // 连击状态 (M3新增)
  int _currentStreak = 0;
  int _maxStreak = 0;

  int get currentStreak => _currentStreak;
  int get maxStreak => _maxStreak;

  void setUserId(String userId) {
    _userId = userId;
  }

  QuestionState get state => _state;

  bool get isLoading => _state == QuestionState.loading;

  String? get errorMessage =>
      _state == QuestionState.error ? _errorMessage : null;

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty ? questions[currentIndex] : null;

  double get accuracy =>
      questions.isEmpty ? 0 : correctCount / questions.length;

  Future<void> loadQuestions(String topic) async {
    _state = QuestionState.loading;
    _errorMessage = null;
    lastTopic = topic;
    notifyListeners();
    try {
      final data = await repository.getQuestions(topic: topic);
      questions = data;
      currentIndex = 0;
      selectedOptionIndex = null;
      isAnswered = false;
      isCompleted = false;
      lastIsCorrect = null;
      correctCount = 0;
      incorrectCount = 0;
      answers.clear();
      _questionStartTime = DateTime.now();
      _currentStreak = 0; // 重置连击 (M3新增)
      _state = QuestionState.loaded;
    } catch (error) {
      _errorMessage = _parseError(error);
      _state = QuestionState.error;
    } finally {
      notifyListeners();
    }
  }

  void selectOption(int index) {
    if (isAnswered) {
      return;
    }
    selectedOptionIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    if (selectedOptionIndex == null || currentQuestion == null || isAnswered) {
      return;
    }
    final correctIndex = currentQuestion!.correctAnswerIndex;
    lastIsCorrect = selectedOptionIndex == correctIndex;
    if (lastIsCorrect == true) {
      correctCount += 1;
      _currentStreak += 1; // 答对递增连击 (M3新增)
      if (_currentStreak > _maxStreak) {
        _maxStreak = _currentStreak; // 更新最大连击 (M3新增)
      }
    } else {
      incorrectCount += 1;
      _currentStreak = 0; // 答错重置连击 (M3新增)
    }
    final duration = _questionStartTime == null
        ? Duration.zero
        : DateTime.now().difference(_questionStartTime!);
    answers.add(
      UserAnswerModel(
        questionId: currentQuestion!.id,
        selectedIndex: selectedOptionIndex!,
        isCorrect: lastIsCorrect ?? false,
        duration: duration,
      ),
    );

    // Record answer to server if repository is available
    _recordAnswer(
      questionId: currentQuestion!.id,
      selectedOptionId: currentQuestion!.options[selectedOptionIndex!].id,
      isCorrect: lastIsCorrect ?? false,
      answerTimeMs: duration.inMilliseconds,
    );

    isAnswered = true;
    notifyListeners();
  }

  Future<void> _recordAnswer({
    required String questionId,
    required String selectedOptionId,
    required bool isCorrect,
    required int answerTimeMs,
  }) async {
    if (_userProgressRepository == null || _userId == null) {
      return;
    }

    try {
      await _userProgressRepository!.recordAnswer(
        userId: _userId!,
        questionId: questionId,
        selectedOptionId: selectedOptionId,
        isCorrect: isCorrect,
        answerTimeMs: answerTimeMs,
      );
    } catch (e) {
      // Silently fail - answer is still recorded locally
      debugPrint('Failed to record answer: $e');
    }
  }

  void nextQuestion() {
    if (currentIndex >= questions.length - 1) {
      isCompleted = true;
      notifyListeners();
      return;
    }
    currentIndex += 1;
    selectedOptionIndex = null;
    isAnswered = false;
    lastIsCorrect = null;
    _questionStartTime = DateTime.now();
    notifyListeners();
  }

  void reset() {
    questions = [];
    currentIndex = 0;
    selectedOptionIndex = null;
    isAnswered = false;
    isCompleted = false;
    lastIsCorrect = null;
    correctCount = 0;
    incorrectCount = 0;
    answers.clear();
    _errorMessage = null;
    _state = QuestionState.initial;
    notifyListeners();
  }

  String _parseError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return '加载失败，请稍后重试';
  }
}
