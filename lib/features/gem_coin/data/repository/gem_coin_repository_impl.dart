import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/gem_coin/data/datasource/gem_coin_remote_datasource.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/entities/gem_coin_history_entity.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/repositories/gem_coin_repository.dart';


class GemCoinRepositoryImpl implements GemCoinRepository {
  final GemCoinRemoteDataSource remoteDataSource;

  GemCoinRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<GEMCoinHistoryEntity>>> getTransactionHistory(
      String uid) async {
    try {
      final result = await remoteDataSource.getTransactionHistory(uid);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}