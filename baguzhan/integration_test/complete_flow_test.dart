import 'package:baguzhan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete flow from home to result', (tester) async {
    await tester.pumpWidget(const BaguzhanApp());
    await tester.pumpAndSettle();

    // 点击 JavaScript 主题
    await tester.tap(find.text('JavaScript'));
    await tester.pumpAndSettle();

    // 等待题目加载
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // JavaScript 主题有 5 道题
    for (var i = 0; i < 5; i += 1) {
      // 等待选项出现
      await tester.pumpAndSettle();

      // 选择选项 A（使用 .first 选择第一个 A）
      final optionA = find.text('A');
      expect(optionA, findsWidgets);
      await tester.tap(optionA.first);
      await tester.pumpAndSettle();

      // 点击提交答案按钮（使用 key）
      final submitButton = find.byKey(const ValueKey('submit-answer'));
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // 等待继续按钮出现
      final continueButton = find.byKey(const ValueKey('continue-button'));
      expect(continueButton, findsOneWidget);

      // 滚动确保按钮可见
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();

      // 点击继续按钮
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
    }

    expect(find.text('答题结果'), findsOneWidget);
    expect(find.text('总题数'), findsOneWidget);
  });
}
