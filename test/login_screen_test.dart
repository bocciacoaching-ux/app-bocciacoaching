import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:boccia_coaching_app/modules/auth/views/login_screen.dart';
import 'package:boccia_coaching_app/core/services/auth_service.dart';
import 'package:boccia_coaching_app/data/providers/session_provider.dart';

/// Servicio de autenticacion falso para pruebas.
class FakeAuth extends AuthService {
  final bool result;
  FakeAuth(this.result);

  @override
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    return result ? {'success': true, 'data': {}} : null;
  }
}

/// Envuelve la pantalla con los providers que necesita.
Widget wrapLogin() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SessionProvider()),
    ],
    child: MaterialApp(
      home: LoginScreen(authService: FakeAuth(true)),
    ),
  );
}

void main() {
  testWidgets('LoginScreen muestra los campos y el boton de acceso',
      (tester) async {
    // Los assets de imagen no se cargan en el entorno de test:
    // ignoramos esos errores para que no hagan fallar la prueba.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.toString();
      if (text.contains('image') ||
          text.contains('asset') ||
          text.contains('codec')) {
        return;
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(wrapLogin());
    await tester.pump();

    // Campos de email y contrasena.
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Boton de inicio de sesion.
    expect(find.text('Iniciar sesión'), findsWidgets);

    // Se puede escribir en ambos campos.
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'password123',
    );
    await tester.pump();

    expect(find.text('user@example.com'), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}
