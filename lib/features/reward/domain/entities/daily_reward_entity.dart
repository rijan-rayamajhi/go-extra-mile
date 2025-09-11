import 'package:equatable/equatable.dart';

class DailyRewardEntity extends Equatable {
  final DateTime? lastScratchAt;
  final int rewardAmount;
  final DateTime nextAvailableAt;
  final int streak;

  const DailyRewardEntity({
    this.lastScratchAt,
    required this.rewardAmount,
    required this.nextAvailableAt,
    required this.streak,
  });

  @override
  List<Object?> get props => [lastScratchAt, rewardAmount, nextAvailableAt, streak];
}