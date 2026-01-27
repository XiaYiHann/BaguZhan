import 'package:baguzhan/data/models/user_answer_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserAnswerModel stores answer data', () {
    final model = UserAnswerModel(
      questionId: 'q1',
      selectedIndex: 2,
      isCorrect: false,
      duration: const Duration(seconds: 3),
    );

    expect(model.questionId, 'q1');
    expect(model.selectedIndex, 2);
    expect(model.isCorrect, false);
    expect(model.duration, const Duration(seconds: 3));
  });
}
