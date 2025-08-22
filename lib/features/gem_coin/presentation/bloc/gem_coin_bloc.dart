import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/usecases/get_transaction_history.dart';
import 'gem_coin_event.dart';
import 'gem_coin_state.dart';

class GemCoinBloc extends Bloc<GemCoinEvent, GemCoinState> {
  final GetTransactionHistory getTransactionHistory;

  GemCoinBloc({required this.getTransactionHistory})
      : super(GemCoinInitial()) {
    on<LoadGemCoinHistory>(_onLoadGemCoinHistory);
  }

  Future<void> _onLoadGemCoinHistory(
      LoadGemCoinHistory event, Emitter<GemCoinState> emit) async {
    emit(GemCoinLoading());

    final result = await getTransactionHistory(event.uid);

    result.fold(
      (failure) => emit(GemCoinError(failure.message)),
      (history) => emit(GemCoinLoaded(history)),
    );
  }
}