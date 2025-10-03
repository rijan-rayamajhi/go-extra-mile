import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_bug_report.dart';
import '../../domain/usecases/get_user_bug_reports.dart';
import '../../domain/usecases/get_bug_report_stats.dart';
import '../../domain/usecases/upload_bug_screenshot.dart';
import '../../domain/repositories/bug_report_repository.dart';
import 'bug_report_event.dart';
import 'bug_report_state.dart';

class BugReportBloc extends Bloc<BugReportEvent, BugReportState> {
  final SubmitBugReport submitBugReport;
  final GetUserBugReports getUserBugReports;
  final GetUserBugReportStats getUserBugReportStats;
  final UploadBugScreenshot uploadBugScreenshot;
  final BugReportRepository bugReportRepository;

  BugReportBloc({
    required this.submitBugReport,
    required this.getUserBugReports,
    required this.getUserBugReportStats,
    required this.uploadBugScreenshot,
    required this.bugReportRepository,
  }) : super(const BugReportInitial()) {
    on<SubmitBugReportEvent>(_onSubmitBugReport);
    on<GetUserBugReportsEvent>(_onGetUserBugReports);
    on<GetBugReportStatsEvent>(_onGetBugReportStats);
    on<UploadBugScreenshotEvent>(_onUploadBugScreenshot);
    on<DeleteBugReportEvent>(_onDeleteBugReport);
    on<RefreshBugReportsEvent>(_onRefreshBugReports);
    on<ClearBugReportStateEvent>(_onClearBugReportState);
  }

  Future<void> _onSubmitBugReport(
    SubmitBugReportEvent event,
    Emitter<BugReportState> emit,
  ) async {
    emit(const BugReportLoading());

    final result = await submitBugReport(
      userId: event.userId,
      title: event.title,
      description: event.description,
      category: event.category,
      priority: event.priority,
      severity: event.severity,
      screenshots: event.screenshots,
      stepsToReproduce: event.stepsToReproduce,
      deviceInfo: event.deviceInfo,
    );

    result.fold(
      (failure) => emit(BugReportError(message: failure.message)),
      (bugReport) => emit(BugReportSubmitted(bugReport: bugReport)),
    );
  }

  Future<void> _onGetUserBugReports(
    GetUserBugReportsEvent event,
    Emitter<BugReportState> emit,
  ) async {
    emit(const BugReportLoading());

    final result = await getUserBugReports(event.userId);

    await result.fold(
      (failure) async => emit(BugReportError(message: failure.message)),
      (bugReports) async {
        // Also get stats when loading bug reports
        final statsResult = await getUserBugReportStats(event.userId);
        await statsResult.fold(
          (failure) async => emit(BugReportLoaded(bugReports: bugReports)),
          (stats) async =>
              emit(BugReportLoaded(bugReports: bugReports, stats: stats)),
        );
      },
    );
  }


  Future<void> _onGetBugReportStats(
    GetBugReportStatsEvent event,
    Emitter<BugReportState> emit,
  ) async {
    emit(const BugReportLoading());

    final result = await getUserBugReportStats(event.userId);

    result.fold(
      (failure) => emit(BugReportError(message: failure.message)),
      (stats) => emit(BugReportStatsLoaded(stats: stats)),
    );
  }

  Future<void> _onUploadBugScreenshot(
    UploadBugScreenshotEvent event,
    Emitter<BugReportState> emit,
  ) async {
    emit(const BugReportLoading());

    final result = await uploadBugScreenshot(
      bugReportId: event.bugReportId,
      imagePath: event.imagePath,
    );

    result.fold(
      (failure) => emit(BugReportError(message: failure.message)),
      (imageUrl) => emit(ScreenshotUploaded(imageUrl: imageUrl)),
    );
  }

  Future<void> _onDeleteBugReport(
    DeleteBugReportEvent event,
    Emitter<BugReportState> emit,
  ) async {
    emit(const BugReportLoading());

    final result = await bugReportRepository.deleteBugReport(
      event.bugReportId,
      event.userId,
    );

    result.fold(
      (failure) => emit(BugReportError(message: failure.message)),
      (_) => emit(const BugReportDeleted()),
    );
  }

  Future<void> _onRefreshBugReports(
    RefreshBugReportsEvent event,
    Emitter<BugReportState> emit,
  ) async {
    add(GetUserBugReportsEvent(userId: event.userId));
  }

  void _onClearBugReportState(
    ClearBugReportStateEvent event,
    Emitter<BugReportState> emit,
  ) {
    emit(const BugReportInitial());
  }
}
