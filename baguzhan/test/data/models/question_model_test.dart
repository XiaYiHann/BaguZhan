import 'package:baguzhan/data/models/question_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QuestionModel fromJson parses fields', () {
    final model = QuestionModel.fromJson({
      'id': 'q1',
      'content': '题目',
      'topic': 'JavaScript',
      'difficulty': 'easy',
      'explanation': '解析',
      'mnemonic': '口诀',
      'scenario': '场景',
      'tags': ['a', 'b'],
      'options': [
        {'id': 'o1', 'optionText': 'A', 'optionOrder': 0, 'isCorrect': false},
        {'id': 'o2', 'optionText': 'B', 'optionOrder': 1, 'isCorrect': true},
      ],
    });

    expect(model.id, 'q1');
    expect(model.content, '题目');
    expect(model.options.length, 2);
    expect(model.correctAnswerIndex, 1);
  });
}
