import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/monetization/domain/entities/cashout_transaction_entity.dart';
import '../entities/monetization_data_entity.dart';

abstract class MonetizationRepository {
  Future<Either<Failure, MonetizationDataEntity>> getMonetizationData();
  Future<Either<Failure, bool>> updateMonetizationStatus(bool isMonetized);
  Future<Either<Failure, bool>> getMonetizationStatus();

  Future<Either<Failure, bool>> createCashoutTransaction(
    CashoutTransactionEntity cashoutTransactionEntity,
  );
  Future<Either<Failure, List<CashoutTransactionEntity>>>
  getCashoutTransactions();
}
