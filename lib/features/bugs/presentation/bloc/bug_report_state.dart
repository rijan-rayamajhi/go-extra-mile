import 'package:equatable/equatable.dart';
import '../../domain/entities/bug_report_entity.dart';

abstract class BugReportState extends Equatable {
  const BugReportState();

  @override
  List<Object?> get props => [];
}

class BugReportInitial extends BugReportState {
  const BugReportInitial();
}

class BugReportLoading extends BugReportState {
  const BugReportLoading();
}

class BugReportLoaded extends BugReportState {
  final List<BugReportEntity> bugReports;
  final Map<String, dynamic>? stats;

  const BugReportLoaded({
    required this.bugReports,
    this.stats,
  });

  @override
  List<Object?> get props => [bugReports, stats];
}

class BugReportStatsLoaded extends BugReportState {
  final Map<String, dynamic> stats;

  const BugReportStatsLoaded({required this.stats});

  @override
  List<Object> get props => [stats];
}

class BugReportSubmitted extends BugReportState {
  final BugReportEntity bugReport;

  const BugReportSubmitted({required this.bugReport});

  @override
  List<Object> get props => [bugReport];
}

class BugReportDeleted extends BugReportState {
  const BugReportDeleted();
}

class ScreenshotUploaded extends BugReportState {
  final String imageUrl;

  const ScreenshotUploaded({required this.imageUrl});

  @override
  List<Object> get props => [imageUrl];
}

class BugReportError extends BugReportState {
  final String message;

  const BugReportError({required this.message});

  @override
  List<Object> get props => [message];
}

class BugReportSuccess extends BugReportState {
  final String message;

  const BugReportSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
