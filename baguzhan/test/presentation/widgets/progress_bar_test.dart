import 'package:baguzhan/presentation/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProgressBar shows progress text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressBar(currentIndex: 0, total: 5),
        ),
      ),
    );

    expect(find.text('第 1 题 / 共 5 题'), findsOneWidget);
  });
}
