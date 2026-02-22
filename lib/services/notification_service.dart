import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class NotificationService {
  final String _base = AppConfig.baseUrl;

  // GET /api/Notification/GetTypes
  Future<Map<String, dynamic>?> getTypes() async {
    try {
      final response = await http.get(Uri.parse('$_base/Notification/GetTypes'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Notification/GetType/{id}
  Future<Map<String, dynamic>?> getType(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Notification/GetType/$id'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Notification/CreateType
  Future<Map<String, dynamic>?> createType({
    String? name,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Notification/CreateType'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'description': description}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /api/Notification/UpdateType
  Future<Map<String, dynamic>?> updateType({
    required int notificationTypeId,
    String? name,
    String? description,
    bool? status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Notification/UpdateType'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'notificationTypeId': notificationTypeId,
          'name': name,
          'description': description,
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

  // GET /api/Notification/GetMessage/{id}
  Future<Map<String, dynamic>?> getMessage(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Notification/GetMessage/$id'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Notification/CreateMessage
  Future<Map<String, dynamic>?> createMessage({
    String? message,
    String? image,
    required int senderId,
    required int receiverId,
    required int notificationTypeId,
    bool? status,
    int? referenceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Notification/CreateMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'image': image,
          'senderId': senderId,
          'receiverId': receiverId,
          'notificationTypeId': notificationTypeId,
          'status': status,
          'referenceId': referenceId,
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

  // PUT /api/Notification/UpdateMessage
  Future<Map<String, dynamic>?> updateMessage({
    required int notificationMessageId,
    String? message,
    String? image,
    required int senderId,
    required int receiverId,
    required int notificationTypeId,
    bool? status,
    int? referenceId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Notification/UpdateMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'notificationMessageId': notificationMessageId,
          'message': message,
          'image': image,
          'senderId': senderId,
          'receiverId': receiverId,
          'notificationTypeId': notificationTypeId,
          'status': status,
          'referenceId': referenceId,
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

  // GET /api/Notification/GetMessagesByCoach/{coachId}?page=&pageSize=
  Future<Map<String, dynamic>?> getMessagesByCoach(
    int coachId, {
    int? page,
    int? pageSize,
  }) async {
    try {
      final uri = Uri.parse('$_base/Notification/GetMessagesByCoach/$coachId').replace(
        queryParameters: {
          if (page != null) 'page': '$page',
          if (pageSize != null) 'pageSize': '$pageSize',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Notification/GetMessagesByAthlete/{athleteId}?page=&pageSize=
  Future<Map<String, dynamic>?> getMessagesByAthlete(
    int athleteId, {
    int? page,
    int? pageSize,
  }) async {
    try {
      final uri = Uri.parse('$_base/Notification/GetMessagesByAthlete/$athleteId').replace(
        queryParameters: {
          if (page != null) 'page': '$page',
          if (pageSize != null) 'pageSize': '$pageSize',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Notification/SendTeamInvitation
  Future<Map<String, dynamic>?> sendTeamInvitation({
    required int coachId,
    String? email,
    required int teamId,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Notification/SendTeamInvitation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'coachId': coachId,
          'email': email,
          'teamId': teamId,
          'message': message,
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

  // PUT /api/Notification/AcceptTeamInvitation/{notificationMessageId}
  Future<Map<String, dynamic>?> acceptTeamInvitation(int notificationMessageId) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Notification/AcceptTeamInvitation/$notificationMessageId'),
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
