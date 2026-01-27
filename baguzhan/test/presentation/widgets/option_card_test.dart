import 'package:baguzhan/presentation/widgets/option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OptionCard renders text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OptionCard(
          indexLabel: 'A',
          text: '选项内容',
          isSelected: false,
          isCorrect: false,
          isIncorrect: false,
          isDisabled: false,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('选项内容'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });
}
