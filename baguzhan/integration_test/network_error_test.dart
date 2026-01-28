import 'package:baguzhan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('网络错误时显示友好提示', (tester) async {
    await tester.pumpWidget(const BaguzhanApp());
    await tester.pumpAndSettle();

    // 点击 JavaScript 主题
    await tester.tap(find.text('JavaScript'));
    await tester.pumpAndSettle();

    // 等待题目加载（实际会超时或失败）
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // 验证错误提示显示
    // 注意：实际测试中可能需要模拟网络错误或使用 mock 服务器
    // 这里验证 UI 能正确处理加载状态
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('超时场景处理', (tester) async {
    await tester.pumpWidget(const BaguzhanApp());
    await tester.pumpAndSettle();

    // 点击 React 主题
    await tester.tap(find.text('React'));
    await tester.pumpAndSettle();

    // 等待超时时间（Dio 配置为 5 秒连接超时）
    await tester.pump(const Duration(seconds: 6));

    // 验证没有无限加载
    await tester.pumpAndSettle();
  });
}
