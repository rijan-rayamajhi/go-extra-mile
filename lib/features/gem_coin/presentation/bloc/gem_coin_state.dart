import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/entities/gem_coin_history_entity.dart';

abstract class GemCoinState extends Equatable {
  const GemCoinState();

  @override
  List<Object?> get props => [];
}

class GemCoinInitial extends GemCoinState {}

class GemCoinLoading extends GemCoinState {}

class GemCoinLoaded extends GemCoinState {
  final List<GEMCoinHistoryEntity> history;

  const GemCoinLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class GemCoinError extends GemCoinState {
  final String message;

  const GemCoinError(this.message);

  @override
  List<Object?> get props => [message];
}