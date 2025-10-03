import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/core/usecases/usecase.dart';
import '../entities/cashout_transaction_entity.dart';
import '../repositories/monetization_repository.dart';

class CreateCashoutTransaction
    implements UseCase<bool, CreateCashoutTransactionParams> {
  final MonetizationRepository repository;

  CreateCashoutTransaction(this.repository);

  @override
  Future<Either<Failure, bool>> call(
    CreateCashoutTransactionParams params,
  ) async {
    return await repository.createCashoutTransaction(params.transaction);
  }
}

class CreateCashoutTransactionParams {
  final CashoutTransactionEntity transaction;

  const CreateCashoutTransactionParams({required this.transaction});
}
