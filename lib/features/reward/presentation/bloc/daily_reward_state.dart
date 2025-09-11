import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/reward/domain/entities/daily_reward_entity.dart';

abstract class DailyRewardState extends Equatable {
  const DailyRewardState();

  @override
  List<Object?> get props => [];
}

class DailyRewardInitial extends DailyRewardState {}

class DailyRewardLoading extends DailyRewardState {}

class DailyRewardLoaded extends DailyRewardState {
  final DailyRewardEntity dailyReward;

  const DailyRewardLoaded(this.dailyReward);

  @override
  List<Object?> get props => [dailyReward];
}

class DailyRewardError extends DailyRewardState {
  final String message;

  const DailyRewardError(this.message);

  @override
  List<Object?> get props => [message];
}