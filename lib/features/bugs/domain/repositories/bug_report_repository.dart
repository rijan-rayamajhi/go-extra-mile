import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bug_report_entity.dart';

abstract class BugReportRepository {
  /// Submit a new bug report
  Future<Either<Failure, BugReportEntity>> submitBugReport(
    BugReportEntity bugReport,
  );

  /// Get all bug reports for a specific user
  Future<Either<Failure, List<BugReportEntity>>> getUserBugReports(
    String userId,
  );

  /// Get a specific bug report by ID
  Future<Either<Failure, BugReportEntity>> getBugReportById(String bugReportId);

  /// Update bug report status (admin only)
  Future<Either<Failure, BugReportEntity>> updateBugReportStatus(
    String bugReportId,
    String status,
    String? adminNotes,
  );

  /// Get bug reports by status filter
  Future<Either<Failure, List<BugReportEntity>>> getBugReportsByStatus(
    String userId,
    String status,
  );

  /// Get bug reports statistics for a user
  Future<Either<Failure, Map<String, dynamic>>> getUserBugReportStats(
    String userId,
  );

  /// Delete a bug report (user can only delete their own pending reports)
  Future<Either<Failure, void>> deleteBugReport(
    String bugReportId,
    String userId,
  );

  /// Upload screenshot for bug report
  Future<Either<Failure, String>> uploadScreenshot(
    String bugReportId,
    String imagePath,
  );

  /// Get all bug reports (admin only)
  Future<Either<Failure, List<BugReportEntity>>> getAllBugReports();

  /// Update bug report reward amount (admin only)
  Future<Either<Failure, BugReportEntity>> updateBugReportReward(
    String bugReportId,
    int rewardAmount,
  );

  /// Update bug report with screenshot URLs
  Future<Either<Failure, BugReportEntity>> updateBugReportScreenshots(
    String bugReportId,
    List<String> screenshotUrls,
  );
}
