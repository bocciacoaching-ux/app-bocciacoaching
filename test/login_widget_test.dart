import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boccia_coaching_app/screens/login_screen.dart';
import 'package:boccia_coaching_app/services/auth_service.dart';

class _FakeAuth extends AuthService {
  final bool result;
  _FakeAuth(this.result);
  @override
  Future<bool> signIn(String email, String password) async {
    return result;
  }
}

void main() {
  testWidgets('LoginScreen shows fields and button, navigates on success', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: _FakeAuth(true))));

    // Verify fields present
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Iniciar sesión'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    // After successful login, Dashboard title should appear (may be present more than once)
    expect(find.text('Dashboard'), findsWidgets);
  });
}
