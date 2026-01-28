import 'package:baguzhan/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BaguzhanApp shows home page', (tester) async {
    await tester.pumpWidget(const BaguzhanApp());
    await tester.pumpAndSettle();

    expect(find.text('八股斩'), findsOneWidget);
    expect(find.text('选择主题'), findsOneWidget);
  });
}
