// MODO DEMO — API simulada en memoria. No se versiona.
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../data/models/microcycle_type_dto.dart';

part 'demo_fixtures.dart';

class DemoUser {
  final String id, email, password, firstName, lastName, rolId, role;
  const DemoUser(this.id, this.email, this.password, this.firstName,
      this.lastName, this.rolId, this.role);

  Map<String, dynamic> toJson() => {
        'userId': id,
        'dni': role == 'Athlete' ? '10203040' : '43876521',
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'address': 'Medellín, Antioquia',
        'country': 'Colombia',
        'image': null,
        'category': role == 'Athlete' ? 'BC1' : null,
        'seniority': null,
        'status': true,
        'rolId': rolId,
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-01T00:00:00Z',
      };
}

const demoCoach = DemoUser('11111111-1111-1111-1111-000000000001',
    'coach@demo.com', 'demo1234', 'Carla', 'Entrenadora',
    AppConstants.roleCoachId, 'Coach');
const demoAthlete = DemoUser('11111111-1111-1111-1111-000000000002',
    'atleta@demo.com', 'demo1234', 'Andrés', 'Atleta',
    AppConstants.roleAthleteId, 'Athlete');
const demoUsers = [demoCoach, demoAthlete];

typedef _Handler = Object? Function(http.BaseRequest req, Map<String, dynamic>? body, RegExpMatch m);

class MockApiClient extends http.BaseClient {
  DemoUser? _current;
  late final _DemoStore _store = _DemoStore(this);

  String _b64(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');

  Map<String, dynamic> _tokens(DemoUser u) {
    final exp = DateTime.now().add(const Duration(days: 30));
    final access = '${_b64({'alg': 'none', 'typ': 'JWT'})}.${_b64({
          'sub': u.id,
          'email': u.email,
          'role': u.role,
          'exp': exp.millisecondsSinceEpoch ~/ 1000,
        })}.demo';
    return {
      'accessToken': access,
      'refreshToken': 'demo-refresh-${u.id}',
      'accessTokenExpiresAt': exp.toIso8601String(),
      'refreshTokenExpiresAt': exp.toIso8601String(),
      'tokenType': 'Bearer',
    };
  }

  DemoUser? _userFromAuth(http.BaseRequest req) {
    final h = req.headers['Authorization'] ?? req.headers['authorization'];
    if (h == null) return _current;
    try {
      final payload = h.split(' ').last.split('.')[1];
      final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload))));
      return demoUsers.firstWhere((u) => u.id == claims['sub']);
    } catch (_) {
      return _current;
    }
  }

  late final Map<String, _Handler> _routes = {
    'POST /v1/auth/login': (req, body, m) {
      final u = demoUsers.where((u) =>
          u.email == (body?['email'] as String?)?.toLowerCase().trim() &&
          u.password == body?['password']);
      if (u.isEmpty) return _Status(401, {'success': false, 'message': 'Usuario demo: coach@demo.com o atleta@demo.com, contraseña demo1234'});
      _current = u.first;
      return {...u.first.toJson(), 'tokens': _tokens(u.first)};
    },
    'POST /v1/auth/refresh': (req, body, m) {
      final id = (body?['refreshToken'] as String? ?? '').replaceFirst('demo-refresh-', '');
      final u = demoUsers.where((u) => u.id == id);
      if (u.isEmpty) return _Status(401, {'success': false});
      _current = u.first;
      return _tokens(u.first);
    },
    'POST /v1/auth/logout': (req, body, m) => {},
    'POST /v1/auth/logout-all': (req, body, m) => {},
    'POST /v1/auth/change-password': (req, body, m) {
      final u = _current ?? demoCoach;
      if (body?['currentPassword'] != u.password) {
        return _Status(400, {'success': false, 'message': 'La contraseña actual es incorrecta (demo: demo1234).'});
      }
      return _tokens(u);
    },
    'POST /v1/auth/password-reset/(request|verify|confirm)': (req, body, m) =>
        {'resetToken': 'demo-reset'},
    ..._store.routes(),
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final bytes = await request.finalize().toBytes();
    Map<String, dynamic>? body;
    try {
      final d = jsonDecode(utf8.decode(bytes));
      if (d is Map<String, dynamic>) body = d;
    } catch (_) {}
    var path = request.url.path;
    final i = path.indexOf('/api');
    if (i >= 0) path = path.substring(i + 4);
    final key = '${request.method} $path';
    _current = _userFromAuth(request) ?? _current;

    Object? result;
    var matched = false;
    for (final e in _routes.entries) {
      final sp = e.key.indexOf(' ');
      if (e.key.substring(0, sp) != request.method) continue;
      final m = RegExp('^${e.key.substring(sp + 1)}\$', caseSensitive: false).firstMatch(path);
      if (m != null) {
        result = e.value(request, body, m);
        matched = true;
        break;
      }
    }
    if (!matched) {
      // ignore: avoid_print
      print('[DEMO] sin simular: $key ${request.url.query}');
      result = request.method == 'GET' ? <dynamic>[] : <String, dynamic>{};
    }
    var status = 200;
    if (result is _Status) {
      status = result.code;
      return _resp(status, result.body, request);
    }
    return _resp(status, {'success': true, 'message': 'OK', 'data': result}, request);
  }

  http.StreamedResponse _resp(int status, Object body, http.BaseRequest req) {
    final b = utf8.encode(jsonEncode(body));
    return http.StreamedResponse(Stream.value(b), status,
        request: req,
        headers: {'content-type': 'application/json; charset=utf-8'},
        contentLength: b.length);
  }
}

class _Status {
  final int code;
  final Object body;
  _Status(this.code, this.body);
}
