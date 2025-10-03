import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/core/usecases/usecase.dart';
import '../entities/cashout_transaction_entity.dart';
import '../repositories/monetization_repository.dart';

class GetCashoutTransactions
    implements UseCase<List<CashoutTransactionEntity>, NoParams> {
  final MonetizationRepository repository;

  GetCashoutTransactions(this.repository);

  @override
  Future<Either<Failure, List<CashoutTransactionEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getCashoutTransactions();
  }
}
