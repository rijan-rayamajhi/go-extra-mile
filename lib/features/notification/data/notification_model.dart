

import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    required super.type,
    required super.userId,
    required super.updatedAt,
  });

  /// Create from Firestore/JSON Map
  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return NotificationModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: _parseDateTime(map['createdAt']) ?? 
                 _parseDateTime(map['time']) ?? 
                 DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'general',
      userId: map['userId'] ?? '',
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Helper method to safely parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) return value;
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Try parsing as timestamp if string parsing fails
        final timestamp = int.tryParse(value);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
        return null;
      }
    }
    
    if (value is int) {
      // Handle Firestore Timestamp or Unix timestamp
      if (value > 1000000000000) {
        // Milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        // Seconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    }
    
    return null;
  }

  /// Convert to JSON/Map (Firestore or API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'time': createdAt.toIso8601String(), // Keep for backward compatibility
      'isRead': isRead,
      'type': type,
      'userId': userId,
      'updatedAt': updatedAt.toIso8601String(),
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
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? userId,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
