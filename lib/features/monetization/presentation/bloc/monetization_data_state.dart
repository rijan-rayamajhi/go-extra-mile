import 'package:equatable/equatable.dart';
import '../../domain/entities/monetization_data_entity.dart';
import '../../domain/entities/cashout_transaction_entity.dart';

abstract class MonetizationDataState extends Equatable {
  const MonetizationDataState();

  @override
  List<Object?> get props => [];
}

class MonetizationDataInitial extends MonetizationDataState {
  const MonetizationDataInitial();
}

class MonetizationDataLoading extends MonetizationDataState {
  const MonetizationDataLoading();
}

class MonetizationDataLoaded extends MonetizationDataState {
  final MonetizationDataEntity? monetizationData;
  final bool? isMonetized;
  final List<CashoutTransactionEntity>? cashoutTransactions;

  const MonetizationDataLoaded({
    this.monetizationData,
    this.isMonetized,
    this.cashoutTransactions,
  });

  // Helper methods to check what data is available
  bool get hasMonetizationData => monetizationData != null;
  bool get hasMonetizationStatus => isMonetized != null;
  bool get hasCashoutTransactions => cashoutTransactions != null;

  // Copy with method for updating specific parts of the state
  MonetizationDataLoaded copyWith({
    MonetizationDataEntity? monetizationData,
    bool? isMonetized,
    List<CashoutTransactionEntity>? cashoutTransactions,
  }) {
    return MonetizationDataLoaded(
      monetizationData: monetizationData ?? this.monetizationData,
      isMonetized: isMonetized ?? this.isMonetized,
      cashoutTransactions: cashoutTransactions ?? this.cashoutTransactions,
    );
  }

  @override
  List<Object?> get props => [
    monetizationData,
    isMonetized,
    cashoutTransactions,
  ];
}

class MonetizationDataError extends MonetizationDataState {
  final String message;

  const MonetizationDataError(this.message);

  @override
  List<Object> get props => [message];
}
