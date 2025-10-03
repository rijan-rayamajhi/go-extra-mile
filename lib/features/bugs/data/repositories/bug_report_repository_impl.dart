import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/bug_report_entity.dart';
import '../../domain/repositories/bug_report_repository.dart';
import '../datasources/bug_report_remote_datasource.dart';
import '../models/bug_report_model.dart';

class BugReportRepositoryImpl implements BugReportRepository {
  final BugReportRemoteDataSource remoteDataSource;

  BugReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BugReportEntity>> submitBugReport(
    BugReportEntity bugReport,
  ) async {
    try {
      final bugReportModel = BugReportModel.fromEntity(bugReport);
      final result = await remoteDataSource.submitBugReport(bugReportModel);

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<BugReportEntity>>> getUserBugReports(
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getUserBugReports(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, BugReportEntity>> getBugReportById(
    String bugReportId,
  ) async {
    try {
      final result = await remoteDataSource.getBugReportById(bugReportId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, BugReportEntity>> updateBugReportStatus(
    String bugReportId,
    String status,
    String? adminNotes,
  ) async {
    try {
      final result = await remoteDataSource.updateBugReportStatus(
        bugReportId,
        status,
        adminNotes,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<BugReportEntity>>> getBugReportsByStatus(
    String userId,
    String status,
  ) async {
    try {
      final result = await remoteDataSource.getBugReportsByStatus(
        userId,
        status,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserBugReportStats(
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getUserBugReportStats(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteBugReport(
    String bugReportId,
    String userId,
  ) async {
    try {
      await remoteDataSource.deleteBugReport(bugReportId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadScreenshot(
    String bugReportId,
    String imagePath,
  ) async {
    try {
      final result = await remoteDataSource.uploadScreenshot(
        bugReportId,
        imagePath,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<BugReportEntity>>> getAllBugReports() async {
    try {
      final result = await remoteDataSource.getAllBugReports();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, BugReportEntity>> updateBugReportReward(
    String bugReportId,
    int rewardAmount,
  ) async {
    try {
      final result = await remoteDataSource.updateBugReportReward(
        bugReportId,
        rewardAmount,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, BugReportEntity>> updateBugReportScreenshots(
    String bugReportId,
    List<String> screenshotUrls,
  ) async {
    try {
      final result = await remoteDataSource.updateBugReportScreenshots(
        bugReportId,
        screenshotUrls,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }
}
