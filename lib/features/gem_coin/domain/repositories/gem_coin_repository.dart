import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import '../entities/gem_coin_history_entity.dart';

abstract class GemCoinRepository {
  /// Get the user's gem coin transaction history
  Future<Either<Failure, List<GEMCoinHistoryEntity>>> getTransactionHistory(String uid);
} 