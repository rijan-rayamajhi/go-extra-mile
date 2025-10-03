import 'package:equatable/equatable.dart';

class BugReportEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String severity;
  final String status;
  final List<String> screenshots;
  final String? stepsToReproduce;
  final String? deviceInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int rewardAmount;
  final String? adminNotes;

  const BugReportEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.severity,
    required this.status,
    required this.screenshots,
    this.stepsToReproduce,
    this.deviceInfo,
    required this.createdAt,
    this.updatedAt,
    required this.rewardAmount,
    this.adminNotes,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        category,
        priority,
        severity,
        status,
        screenshots,
        stepsToReproduce,
        deviceInfo,
        createdAt,
        updatedAt,
        rewardAmount,
        adminNotes,
      ];

  BugReportEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? severity,
    String? status,
    List<String>? screenshots,
    String? stepsToReproduce,
    String? deviceInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? rewardAmount,
    String? adminNotes,
  }) {
    return BugReportEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      screenshots: screenshots ?? this.screenshots,
      stepsToReproduce: stepsToReproduce ?? this.stepsToReproduce,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}

enum BugCategory {
  uiUx('UI/UX'),
  functionality('Functionality'),
  performance('Performance'),
  security('Security'),
  navigation('Navigation'),
  data('Data'),
  other('Other');

  const BugCategory(this.value);
  final String value;
}

enum BugPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const BugPriority(this.value);
  final String value;
}

enum BugSeverity {
  minor('Minor'),
  major('Major'),
  critical('Critical'),
  blocker('Blocker');

  const BugSeverity(this.value);
  final String value;
}

enum BugStatus {
  pending('Pending'),
  underReview('Under Review'),
  inProgress('In Progress'),
  fixed('Fixed'),
  rejected('Rejected'),
  duplicate('Duplicate');

  const BugStatus(this.value);
  final String value;
}
