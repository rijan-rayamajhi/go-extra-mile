import 'package:equatable/equatable.dart';

abstract class BugReportEvent extends Equatable {
  const BugReportEvent();

  @override
  List<Object?> get props => [];
}

class SubmitBugReportEvent extends BugReportEvent {
  final String userId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String severity;
  final List<String> screenshots;
  final String? stepsToReproduce;
  final String? deviceInfo;

  const SubmitBugReportEvent({
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.severity,
    required this.screenshots,
    this.stepsToReproduce,
    this.deviceInfo,
  });

  @override
  List<Object?> get props => [
        userId,
        title,
        description,
        category,
        priority,
        severity,
        screenshots,
        stepsToReproduce,
        deviceInfo,
      ];
}

class GetUserBugReportsEvent extends BugReportEvent {
  final String userId;

  const GetUserBugReportsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetBugReportsByStatusEvent extends BugReportEvent {
  final String userId;
  final String status;

  const GetBugReportsByStatusEvent({
    required this.userId,
    required this.status,
  });

  @override
  List<Object> get props => [userId, status];
}

class GetBugReportStatsEvent extends BugReportEvent {
  final String userId;

  const GetBugReportStatsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UploadBugScreenshotEvent extends BugReportEvent {
  final String bugReportId;
  final String imagePath;

  const UploadBugScreenshotEvent({
    required this.bugReportId,
    required this.imagePath,
  });

  @override
  List<Object> get props => [bugReportId, imagePath];
}

class DeleteBugReportEvent extends BugReportEvent {
  final String bugReportId;
  final String userId;

  const DeleteBugReportEvent({
    required this.bugReportId,
    required this.userId,
  });

  @override
  List<Object> get props => [bugReportId, userId];
}

class RefreshBugReportsEvent extends BugReportEvent {
  final String userId;

  const RefreshBugReportsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ClearBugReportStateEvent extends BugReportEvent {
  const ClearBugReportStateEvent();
}
