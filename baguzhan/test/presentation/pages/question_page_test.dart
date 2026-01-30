import 'package:baguzhan/data/datasources/local_question_datasource.dart';
import 'package:baguzhan/data/repositories/local_question_repository.dart';
import 'package:baguzhan/presentation/pages/question_page.dart';
import 'package:baguzhan/presentation/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('QuestionPage loads and shows question', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => QuestionProvider(
          LocalQuestionRepository(LocalQuestionDatasource()),
        ),
        child: const MaterialApp(
          home: QuestionPage(topic: 'JavaScript'),
        ),
      ),
    );

    // 使用 pump() 而不是 pumpAndSettle() 避免无限动画等待
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('JavaScript'), findsWidgets);
    expect(find.byType(QuestionPage), findsOneWidget);
    expect(find.textContaining('题'), findsWidgets);
  });

  testWidgets('QuestionPage submit flow shows feedback', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => QuestionProvider(
          LocalQuestionRepository(LocalQuestionDatasource()),
        ),
        child: const MaterialApp(
          home: QuestionPage(topic: 'JavaScript'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('A').first);
    await tester.pump();
    final submitFinder = find.byKey(const ValueKey('submit-answer'));
    await tester.scrollUntilVisible(submitFinder, 200);
    await tester.tap(submitFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('回答'), findsOneWidget);
  });
}
