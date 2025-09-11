import 'package:equatable/equatable.dart';

abstract class DailyRewardEvent extends Equatable {
  const DailyRewardEvent();

  @override
  List<Object?> get props => [];
}

class GetDailyRewardEvent extends DailyRewardEvent {
  final String userId;

  const GetDailyRewardEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateRewardEvent extends DailyRewardEvent {
  final String userId;
  final int rewardAmount;

  const UpdateRewardEvent(this.userId, this.rewardAmount);

  @override
  List<Object?> get props => [userId, rewardAmount];
}
