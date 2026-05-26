import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../../data/models/microcycle_type_dto.dart';

/// Servicio HTTP para el controlador MicrocycleType del backend.
class MicrocycleTypeService {
  final String _base = AppConfig.baseUrl;

  // ─── GET /api/MicrocycleType/GetAll ─────────────────────────────
  /// Retorna la lista de tipos de microciclo con sus días y porcentajes.
  Future<List<MicrocycleTypeDto>?> getAll() async {
    try {
      final response = await http.get(
        Uri.parse('$_base/MicrocycleType/GetAll'),
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint(
          '[MicrocycleTypeService] GetAll status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) =>
                  MicrocycleTypeDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('[MicrocycleTypeService] GetAll error: $e');
      return null;
    }
  }
}
