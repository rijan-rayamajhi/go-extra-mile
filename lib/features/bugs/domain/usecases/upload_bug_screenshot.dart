import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/bug_report_repository.dart';

class UploadBugScreenshot {
  final BugReportRepository repository;

  UploadBugScreenshot({required this.repository});

  Future<Either<Failure, String>> call({
    required String bugReportId,
    required String imagePath,
  }) async {
    if (bugReportId.trim().isEmpty) {
      return Left(ValidationFailure('Bug report ID is required'));
    }
    if (imagePath.trim().isEmpty) {
      return Left(ValidationFailure('Image path is required'));
    }

    return await repository.uploadScreenshot(bugReportId, imagePath);
  }
}
