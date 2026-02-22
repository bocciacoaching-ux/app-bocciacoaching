import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class EmailService {
  final String _base = AppConfig.baseUrl;

  // POST /api/Email/SendCodeVerify
  Future<List<dynamic>?> sendCodeVerify({
    String? toEmail,
    String? code,
    required int minutesValid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Email/SendCodeVerify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toEmail': toEmail,
          'code': code,
          'minutesValid': minutesValid,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Email/ValidateCode
  Future<List<dynamic>?> validateCode({
    String? toEmail,
    String? code,
    required int minutesValid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Email/ValidateCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toEmail': toEmail,
          'code': code,
          'minutesValid': minutesValid,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
