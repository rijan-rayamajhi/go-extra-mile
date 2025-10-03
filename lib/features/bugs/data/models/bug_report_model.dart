import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bug_report_entity.dart';

class BugReportModel extends BugReportEntity {
  const BugReportModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.category,
    required super.priority,
    required super.severity,
    required super.status,
    required super.screenshots,
    super.stepsToReproduce,
    super.deviceInfo,
    required super.createdAt,
    super.updatedAt,
    required super.rewardAmount,
    super.adminNotes,
  });

  factory BugReportModel.fromEntity(BugReportEntity entity) {
    return BugReportModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      priority: entity.priority,
      severity: entity.severity,
      status: entity.status,
      screenshots: entity.screenshots,
      stepsToReproduce: entity.stepsToReproduce,
      deviceInfo: entity.deviceInfo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      rewardAmount: entity.rewardAmount,
      adminNotes: entity.adminNotes,
    );
  }

  factory BugReportModel.fromJson(Map<String, dynamic> json) {
    return BugReportModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      screenshots: List<String>.from(json['screenshots'] as List),
      stepsToReproduce: json['stepsToReproduce'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      rewardAmount: json['rewardAmount'] as int,
      adminNotes: json['adminNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'severity': severity,
      'status': status,
      'screenshots': screenshots,
      'stepsToReproduce': stepsToReproduce,
      'deviceInfo': deviceInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'rewardAmount': rewardAmount,
      'adminNotes': adminNotes,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'severity': severity,
      'status': status,
      'screenshots': screenshots,
      'stepsToReproduce': stepsToReproduce,
      'deviceInfo': deviceInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'rewardAmount': rewardAmount,
      'adminNotes': adminNotes,
    };
  }

  factory BugReportModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return BugReportModel(
      id: id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      priority: data['priority'] as String,
      severity: data['severity'] as String,
      status: data['status'] as String,
      screenshots: List<String>.from(data['screenshots'] as List),
      stepsToReproduce: data['stepsToReproduce'] as String?,
      deviceInfo: data['deviceInfo'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      rewardAmount: data['rewardAmount'] as int,
      adminNotes: data['adminNotes'] as String?,
    );
  }
}
