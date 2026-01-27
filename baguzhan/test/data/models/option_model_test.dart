import 'package:baguzhan/data/models/option_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OptionModel fromJson parses fields', () {
    final model = OptionModel.fromJson({
      'id': 'o1',
      'optionText': '选项',
      'optionOrder': 2,
      'isCorrect': true,
    });

    expect(model.id, 'o1');
    expect(model.optionText, '选项');
    expect(model.optionOrder, 2);
    expect(model.isCorrect, true);
  });
}
