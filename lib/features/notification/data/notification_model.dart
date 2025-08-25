

import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.time,
    required super.isRead,
    required super.type,
  });

  /// Create from Firestore/JSON Map
  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return NotificationModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      time: map['time'] is DateTime
          ? map['time']
          : DateTime.tryParse(map['time'].toString()) ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'general',
    );
  }

  /// Convert to JSON/Map (Firestore or API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  /// Create from JSON string
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel.fromMap(json);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Copy with updated values
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
