import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  final String _base = AppConfig.baseUrl;

  // POST /api/User/login
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/User/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    // Limpia la sesión local; extender con llamada al servidor si la API lo requiere.
  }
}
