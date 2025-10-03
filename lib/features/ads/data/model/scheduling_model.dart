import '../../domain/entities/scheduling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulingModel extends Scheduling {
  const SchedulingModel({
    required super.enabled,
    super.startDate,
    super.endDate,
  });

  factory SchedulingModel.fromJson(Map<String, dynamic> json) {
    return SchedulingModel(
      enabled: json['enabled'] as bool? ?? false,
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory SchedulingModel.fromEntity(Scheduling entity) {
    return SchedulingModel(
      enabled: entity.enabled,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  /// Helper method to parse DateTime from various formats (Timestamp, String, etc.)
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return null;
    }

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    return null;
  }
}
