import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bug_report_entity.dart';
import '../repositories/bug_report_repository.dart';

class GetUserBugReports {
  final BugReportRepository repository;

  GetUserBugReports({required this.repository});

  Future<Either<Failure, List<BugReportEntity>>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('User ID is required'));
    }

    return await repository.getUserBugReports(userId);
  }
}

class GetBugReportsByStatus {
  final BugReportRepository repository;

  GetBugReportsByStatus({required this.repository});

  Future<Either<Failure, List<BugReportEntity>>> call(
    String userId,
    String status,
  ) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('User ID is required'));
    }
    if (status.trim().isEmpty) {
      return Left(ValidationFailure('Status is required'));
    }

    return await repository.getBugReportsByStatus(userId, status);
  }
}
