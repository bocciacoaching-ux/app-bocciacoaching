// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boccia_coaching_app/main.dart';

void main() {
  testWidgets('App shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // The login greeting should be visible
    expect(find.text('Hola de nuevo!'), findsOneWidget);

    // Email and password fields should be present
    expect(find.byType(TextFormField), findsNWidgets(2));
    // Login button should be present
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
