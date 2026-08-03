import 'dart:convert';
import '../network/http_logger.dart';
import '../constants/app_config.dart';

class EmailService {
  final String _base = AppConfig.baseUrl;

  // POST /api/Email/SendCodeVerify
  Future<List<dynamic>?> sendCodeVerify({
    String? toEmail,
    String? code,
    required int minutesValid,
  }) async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base/Email/SendCodeVerify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toEmail': toEmail,
          'code': code,
          'minutesValid': minutesValid,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is List) return decoded;
          return [decoded];
        } catch (_) {
          return <dynamic>[];
        }
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
      final response = await HttpLogger.post(
        Uri.parse('$_base/Email/ValidateCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toEmail': toEmail,
          'code': code,
          'minutesValid': minutesValid,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is List) return decoded;
          return [decoded];
        } catch (_) {
          return <dynamic>[];
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Email/TestSmtpConnectivity
  Future<bool> testSmtpConnectivity() async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base/Email/TestSmtpConnectivity'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // POST /api/Email/SendTestEmail?toEmail=
  Future<bool> sendTestEmail({String? toEmail}) async {
    try {
      final uri = Uri.parse('$_base/Email/SendTestEmail').replace(
        queryParameters: {
          if (toEmail != null) 'toEmail': toEmail,
        },
      );
      final response = await HttpLogger.post(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // POST /api/EmailTest/test-email
  Future<bool> emailTestSend({String? toEmail, String? toName}) async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base/EmailTest/test-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toEmail': toEmail,
          'toName': toName,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // POST /api/EmailTest/diagnose
  Future<bool> emailTestDiagnose() async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base/EmailTest/diagnose'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // POST /api/EmailTest/ping
  Future<bool> emailTestPing() async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base/EmailTest/ping'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
