import 'package:flutter_test/flutter_test.dart';
import 'package:cs_builder/main.dart';

void main() {
  testWidgets('CS Builder app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CSBuilderApp());
    expect(find.text('CS Builder'), findsAny);
  });
}
