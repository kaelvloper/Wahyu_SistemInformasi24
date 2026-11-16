import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_informasi24/main.dart';

void main() {
  testWidgets('Inventaris test', (WidgetTester tester) async {
    // Ubah MyApp() menjadi InventarisPage() sesuai main.dart tim Anda
    await tester.pumpWidget(const MaterialApp(home: InventarisPage()));

    expect(find.text('Inventaris Laboratorium'), findsOneWidget);
  });
}