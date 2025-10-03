import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/usecases/usecase.dart';
import '../../domain/usecases/get_monetization_data.dart';
import '../../domain/usecases/update_monetization_status.dart' as usecases;
import '../../domain/usecases/get_monetization_status.dart' as usecases;
import '../../domain/usecases/create_cashout_transaction.dart' as usecases;
import '../../domain/usecases/get_cashout_transactions.dart';
import 'monetization_data_event.dart';
import 'monetization_data_state.dart';

class MonetizationDataBloc
    extends Bloc<MonetizationDataEvent, MonetizationDataState> {
  final GetMonetizationData getMonetizationData;
  final usecases.UpdateMonetizationStatus updateMonetizationStatus;
  final usecases.GetMonetizationStatus getMonetizationStatus;
  final usecases.CreateCashoutTransaction createCashoutTransaction;
  final GetCashoutTransactions getCashoutTransactions;

  MonetizationDataBloc({
    required this.getMonetizationData,
    required this.updateMonetizationStatus,
    required this.getMonetizationStatus,
    required this.createCashoutTransaction,
    required this.getCashoutTransactions,
  }) : super(const MonetizationDataInitial()) {
    on<LoadMonetizationData>(_onLoadMonetizationData);
    on<UpdateMonetizationStatus>(_onUpdateMonetizationStatus);
    on<GetMonetizationStatus>(_onGetMonetizationStatus);
    on<CreateCashoutTransaction>(_onCreateCashoutTransaction);
    on<LoadCashoutTransactions>(_onLoadCashoutTransactions);
  }

  Future<void> _onLoadMonetizationData(
    LoadMonetizationData event,
    Emitter<MonetizationDataState> emit,
  ) async {
    emit(const MonetizationDataLoading());

    final result = await getMonetizationData(NoParams());

    result.fold((failure) => emit(MonetizationDataError(failure.message)), (
      data,
    ) {
      // If we already have some data in the current state, preserve it
      final currentState = state;
      if (currentState is MonetizationDataLoaded) {
        emit(currentState.copyWith(monetizationData: data));
      } else {
        emit(MonetizationDataLoaded(monetizationData: data));
      }
    });
  }

  Future<void> _onUpdateMonetizationStatus(
    UpdateMonetizationStatus event,
    Emitter<MonetizationDataState> emit,
  ) async {
    emit(const MonetizationDataLoading());

    final result = await updateMonetizationStatus(
      usecases.UpdateMonetizationStatusParams(isMonetized: event.isMonetized),
    );

    result.fold((failure) => emit(MonetizationDataError(failure.message)), (
      isMonetized,
    ) {
      // Preserve existing data and update monetization status
      final currentState = state;
      if (currentState is MonetizationDataLoaded) {
        emit(currentState.copyWith(isMonetized: isMonetized));
      } else {
        emit(MonetizationDataLoaded(isMonetized: isMonetized));
      }
    });
  }

  Future<void> _onGetMonetizationStatus(
    GetMonetizationStatus event,
    Emitter<MonetizationDataState> emit,
  ) async {
    // Don't emit loading if we already have data - just update in background
    final currentState = state;
    if (currentState is! MonetizationDataLoaded) {
      emit(const MonetizationDataLoading());
    }

    final result = await getMonetizationStatus(NoParams());

    result.fold((failure) => emit(MonetizationDataError(failure.message)), (
      isMonetized,
    ) {
      // Always preserve existing data and only update monetization status
      if (currentState is MonetizationDataLoaded) {
        emit(currentState.copyWith(isMonetized: isMonetized));
      } else {
        emit(MonetizationDataLoaded(isMonetized: isMonetized));
      }
    });
  }

  Future<void> _onCreateCashoutTransaction(
    CreateCashoutTransaction event,
    Emitter<MonetizationDataState> emit,
  ) async {
    emit(const MonetizationDataLoading());

    final result = await createCashoutTransaction(
      usecases.CreateCashoutTransactionParams(transaction: event.transaction),
    );

    result.fold((failure) => emit(MonetizationDataError(failure.message)), (
      success,
    ) {
      if (success) {
        // After successful creation, reload the cashout transactions
        add(const LoadCashoutTransactions());
      } else {
        emit(
          const MonetizationDataError('Failed to create cashout transaction'),
        );
      }
    });
  }

  Future<void> _onLoadCashoutTransactions(
    LoadCashoutTransactions event,
    Emitter<MonetizationDataState> emit,
  ) async {
    // Don't emit loading if we already have data - just update in background
    final currentState = state;
    if (currentState is! MonetizationDataLoaded) {
      emit(const MonetizationDataLoading());
    }

    final result = await getCashoutTransactions(NoParams());

    result.fold((failure) => emit(MonetizationDataError(failure.message)), (
      transactions,
    ) {
      // Always preserve existing data and only update cashout transactions
      if (currentState is MonetizationDataLoaded) {
        emit(currentState.copyWith(cashoutTransactions: transactions));
      } else {
        emit(MonetizationDataLoaded(cashoutTransactions: transactions));
      }
    });
  }
}
