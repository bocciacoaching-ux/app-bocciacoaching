import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class UserService {
  final String _base = AppConfig.baseUrl;

  // GET /api/User
  Future<Map<String, dynamic>?> getInfoUser() async {
    try {
      final response = await http.get(Uri.parse('$_base/User'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/User/AddInfoUser
  Future<Map<String, dynamic>?> addInfoUser({
    String? email,
    String? region,
    String? password,
    required int rol,
    String? category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/User/AddInfoUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'region': region,
          'password': password,
          'rol': rol,
          'category': category,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/User/ValidateEmail
  Future<Map<String, dynamic>?> validateEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/User/ValidateEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /api/User/UpdatePassword
  Future<Map<String, dynamic>?> updatePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/User/UpdatePassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /api/User/UpdateUserInfo
  Future<Map<String, dynamic>?> updateUserInfo({
    required int userId,
    String? dni,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? country,
    String? image,
    String? category,
    DateTime? seniority,
    bool? status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/User/UpdateUserInfo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'dni': dni,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'address': address,
          'country': country,
          'image': image,
          'category': category,
          'seniority': seniority?.toIso8601String(),
          'status': status,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
