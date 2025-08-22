import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/entities/gem_coin_history_entity.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/repositories/gem_coin_repository.dart';


class GetTransactionHistory {
  final GemCoinRepository repository;

  GetTransactionHistory(this.repository);

  Future<Either<Failure, List<GEMCoinHistoryEntity>>> call(String uid) async {
    return await repository.getTransactionHistory(uid);
  }
}