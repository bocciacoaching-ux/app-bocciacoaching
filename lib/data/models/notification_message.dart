/// Modelo que representa un mensaje/notificación devuelto por la API.
class NotificationMessage {
  final int notificationMessageId;
  final String? message;
  final String? image;
  final int senderId;
  final int receiverId;
  final int notificationTypeId;
  final String? typeName;
  final bool isRead; // status en la API
  final int? referenceId;
  final DateTime? createdAt;

  const NotificationMessage({
    required this.notificationMessageId,
    this.message,
    this.image,
    required this.senderId,
    required this.receiverId,
    required this.notificationTypeId,
    this.typeName,
    required this.isRead,
    this.referenceId,
    this.createdAt,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      notificationMessageId: (json['notificationMessageId'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
      image: json['image'] as String?,
      senderId: (json['senderId'] as num?)?.toInt() ?? 0,
      receiverId: (json['receiverId'] as num?)?.toInt() ?? 0,
      notificationTypeId: (json['notificationTypeId'] as num?)?.toInt() ?? 0,
      typeName: json['typeName'] as String?,
      isRead: json['status'] as bool? ?? false,
      referenceId: (json['referenceId'] as num?)?.toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationMessageId': notificationMessageId,
        'message': message,
        'image': image,
        'senderId': senderId,
        'receiverId': receiverId,
        'notificationTypeId': notificationTypeId,
        'typeName': typeName,
        'status': isRead,
        'referenceId': referenceId,
        'createdAt': createdAt?.toIso8601String(),
      };

  NotificationMessage copyWith({bool? isRead}) {
    return NotificationMessage(
      notificationMessageId: notificationMessageId,
      message: message,
      image: image,
      senderId: senderId,
      receiverId: receiverId,
      notificationTypeId: notificationTypeId,
      typeName: typeName,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId,
      createdAt: createdAt,
    );
  }

  /// Tiempo relativo para mostrar en la UI.
  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hace 1 día';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return 'Hace ${(diff.inDays / 7).floor()} semana(s)';
  }

  /// Si fue creada hoy.
  bool get isToday {
    if (createdAt == null) return false;
    final now = DateTime.now();
    return createdAt!.year == now.year &&
        createdAt!.month == now.month &&
        createdAt!.day == now.day;
  }
}
