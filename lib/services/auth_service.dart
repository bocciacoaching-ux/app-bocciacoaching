import 'dart:async';

class AuthService {
  /// Simula una llamada de red para autenticar.
  /// Devuelve true si email y password cumplen una validación simple.
  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) return false;
    // Demo: credenciales de ejemplo
    if (email == 'user@example.com' && password == 'password123') {
      return true;
    }
    // También aceptar cualquier combinación que tenga formato simple de email
    final emailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (emailValid.hasMatch(email) && password.length >= 6) return true;
    return false;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return;
  }
}
