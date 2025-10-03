import 'package:equatable/equatable.dart';
import '../../domain/entities/cashout_transaction_entity.dart';

abstract class MonetizationDataEvent extends Equatable {
  const MonetizationDataEvent();

  @override
  List<Object> get props => [];
}

class LoadMonetizationData extends MonetizationDataEvent {
  const LoadMonetizationData();
}

class UpdateMonetizationStatus extends MonetizationDataEvent {
  final bool isMonetized;
  
  const UpdateMonetizationStatus(this.isMonetized);
  
  @override
  List<Object> get props => [isMonetized];
}

class GetMonetizationStatus extends MonetizationDataEvent {
  const GetMonetizationStatus();
}

class CreateCashoutTransaction extends MonetizationDataEvent {
  final CashoutTransactionEntity transaction;
  
  const CreateCashoutTransaction(this.transaction);
  
  @override
  List<Object> get props => [transaction];
}

class LoadCashoutTransactions extends MonetizationDataEvent {
  const LoadCashoutTransactions();
}
