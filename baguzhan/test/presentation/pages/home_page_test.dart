import 'package:baguzhan/core/theme/app_theme.dart';
import 'package:baguzhan/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomePage shows topics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );

    expect(find.text('八股斩'), findsOneWidget);
    expect(find.text('JavaScript'), findsOneWidget);
    expect(find.text('React'), findsOneWidget);
    expect(find.text('Vue'), findsOneWidget);
  });
}
