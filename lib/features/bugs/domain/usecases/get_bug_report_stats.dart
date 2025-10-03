import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/bug_report_repository.dart';

class GetUserBugReportStats {
  final BugReportRepository repository;

  GetUserBugReportStats({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('User ID is required'));
    }

    return await repository.getUserBugReportStats(userId);
  }
}
