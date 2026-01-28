class UserAnswerModel {
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;
  final Duration duration;

  const UserAnswerModel({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.duration,
  });
}
