import 'package:flutter/foundation.dart';
import '../models/notification_message.dart';
import '../providers/team_provider.dart';
import '../../core/services/notification_service.dart';

/// Estado de carga del provider.
enum NotificationLoadStatus { idle, loading, success, error }

/// Provider que gestiona las notificaciones del usuario en curso.
///
/// Uso:
/// ```dart
/// context.read<NotificationProvider>().fetchForUser(
///   userId: session.userId,
///   isCoach: session.isCoach,
/// );
/// ```
class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationMessage> _notifications = [];
  NotificationLoadStatus _status = NotificationLoadStatus.idle;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<NotificationMessage> get notifications =>
      List.unmodifiable(_notifications);

  NotificationLoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == NotificationLoadStatus.loading;
  bool get hasError => _status == NotificationLoadStatus.error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Notificaciones de hoy.
  List<NotificationMessage> get todayNotifications =>
      _notifications.where((n) => n.isToday).toList();

  /// Notificaciones anteriores (no de hoy).
  List<NotificationMessage> get earlierNotifications =>
      _notifications.where((n) => !n.isToday).toList();

  // ── Fetch ────────────────────────────────────────────────────────────────

  /// Carga las notificaciones del usuario.
  ///
  /// Si [isCoach] es `true` usa `GetMessagesByCoach`, si no `GetMessagesByAthlete`.
  Future<void> fetchForUser({
    required String userId,
    required bool isCoach,
    int page = 1,
    int pageSize = 50,
  }) async {
    _status = NotificationLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic>? result;
      if (isCoach) {
        result = await _service.getMessagesByCoach(
          userId,
          page: page,
          pageSize: pageSize,
        );
      } else {
        result = await _service.getMessagesByAthlete(
          userId,
          page: page,
          pageSize: pageSize,
        );
      }

      if (result != null) {
        final rawList = _extractList(result);
        _notifications = rawList
            .map((e) => NotificationMessage.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) {
            // Más reciente primero
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
        _status = NotificationLoadStatus.success;
      } else {
        _status = NotificationLoadStatus.error;
        _errorMessage = 'No se pudieron cargar las notificaciones.';
      }
    } catch (e) {
      _status = NotificationLoadStatus.error;
      _errorMessage = 'Error inesperado: $e';
    }

    notifyListeners();
  }

  // ── Marcar como leída ────────────────────────────────────────────────────

  /// Marca una notificación como leída (status = true) en la API y localmente.
  Future<void> markAsRead(NotificationMessage notification) async {
    if (notification.isRead) return;

    // Optimistic update
    _updateLocally(notification.notificationMessageId, isRead: true);
    notifyListeners();

    try {
      await _service.updateMessage(
        notificationMessageId: notification.notificationMessageId,
        message: notification.message,
        image: notification.image,
        senderId: notification.senderId,
        receiverId: notification.receiverId,
        notificationTypeId: notification.notificationTypeId,
        status: true,
        referenceId: notification.referenceId,
      );
    } catch (_) {
      // Revert on failure
      _updateLocally(notification.notificationMessageId, isRead: false);
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leídas.
  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // Optimistic: mark all locally
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    // Persist each in background (fire & forget)
    for (final n in unread) {
      _service.updateMessage(
        notificationMessageId: n.notificationMessageId,
        message: n.message,
        image: n.image,
        senderId: n.senderId,
        receiverId: n.receiverId,
        notificationTypeId: n.notificationTypeId,
        status: true,
        referenceId: n.referenceId,
      );
    }
  }

  // ── Invitaciones de equipo ───────────────────────────────────────────────

  /// Acepta una invitación de equipo (tipo 2).
  ///
  /// Llama a `PUT /api/Notification/AcceptTeamInvitation/{id}`, marca la
  /// notificación como leída y recarga los equipos del atleta.
  /// [teamProvider] y [userId] son necesarios para refrescar los equipos.
  /// Retorna `true` si tuvo éxito.
  Future<bool> acceptInvitation(
    NotificationMessage notification, {
    required TeamProvider teamProvider,
    required String userId,
  }) async {
    try {
      final result = await _service.acceptTeamInvitation(
          notification.notificationMessageId);
      if (result != null) {
        _updateLocally(notification.notificationMessageId, isRead: true);
        notifyListeners();
        // Recargar equipos del atleta para que vea el nuevo equipo
        await teamProvider.fetchTeams(userId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Rechaza una invitación de equipo marcándola como leída sin aceptar.
  ///
  /// Retorna `true` si tuvo éxito.
  Future<bool> declineInvitation(NotificationMessage notification) async {
    try {
      await _service.updateMessage(
        notificationMessageId: notification.notificationMessageId,
        message: notification.message,
        image: notification.image,
        senderId: notification.senderId,
        receiverId: notification.receiverId,
        notificationTypeId: notification.notificationTypeId,
        status: true, // marcar como leída / procesada
        referenceId: notification.referenceId,
      );
      _updateLocally(notification.notificationMessageId, isRead: true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _updateLocally(String id, {required bool isRead}) {
    _notifications = _notifications.map((n) {
      return n.notificationMessageId == id ? n.copyWith(isRead: isRead) : n;
    }).toList();
  }

  /// La API puede devolver la lista directamente o dentro de una clave `data`.
  List<dynamic> _extractList(Map<String, dynamic> result) {
    if (result['data'] is List) return result['data'] as List<dynamic>;
    if (result['items'] is List) return result['items'] as List<dynamic>;
    if (result['notifications'] is List) {
      return result['notifications'] as List<dynamic>;
    }
    // A veces la respuesta es la lista envuelta en la raíz
    if (result['value'] is List) return result['value'] as List<dynamic>;
    return [];
  }

  void clear() {
    _notifications = [];
    _status = NotificationLoadStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
