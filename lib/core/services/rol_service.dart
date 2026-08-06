import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/http_logger.dart';
import '../constants/app_config.dart';
import '../constants/api_endpoints.dart';
import '../../data/models/rol.dart';

/// Servicio HTTP para el controlador Rol del backend.
class RolService {
  final String _base = AppConfig.baseUrl;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // ─── GET /api/Rol/GetAll ────────────────────────────────────────
  Future<List<Rol>?> getAll() async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base${ApiEndpoints.rolGetAll}'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => Rol.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('[RolService] getAll error: $e');
      return null;
    }
  }

  // ─── GET /api/Rol/GetById/{id} ──────────────────────────────────
  Future<Rol?> getById(String id) async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base${ApiEndpoints.rolGetById(id)}'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return Rol.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[RolService] getById error: $e');
      return null;
    }
  }

  // ─── POST /api/Rol/Create ───────────────────────────────────────
  Future<bool> create(Rol rol) async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base${ApiEndpoints.rolCreate}'),
        headers: _headers,
        body: jsonEncode(rol.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[RolService] create error: $e');
      return false;
    }
  }

  // ─── PUT /api/Rol/Update ────────────────────────────────────────
  Future<bool> update(Rol rol) async {
    try {
      final response = await HttpLogger.put(
        Uri.parse('$_base${ApiEndpoints.rolUpdate}'),
        headers: _headers,
        body: jsonEncode(rol.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[RolService] update error: $e');
      return false;
    }
  }

  // ─── DELETE /api/Rol/Delete/{id} ────────────────────────────────
  Future<bool> delete(String id) async {
    try {
      final response = await HttpLogger.delete(
        Uri.parse('$_base${ApiEndpoints.rolDelete(id)}'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[RolService] delete error: $e');
      return false;
    }
  }
}
