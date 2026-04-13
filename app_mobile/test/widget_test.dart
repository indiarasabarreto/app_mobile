// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_mobile/main.dart';

void main() {
  testWidgets('TodoListScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: TodoListScreen(token: 'dummy_token')));

    // Verify that the app bar title is present.
    expect(find.text('Lista de Limpeza'), findsOneWidget);

    // Since it's a smoke test, we don't need to test further interactions
    // as they require API mocking for proper testing.
  });
}
