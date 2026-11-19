import 'package:flutter_test/flutter_test.dart';

import 'package:sistem_informasi24/main.dart';

void main() {
  testWidgets('Smoke test app load', (WidgetTester tester) async {
    await tester.pumpWidget(const InventarisApp());
  });
}
