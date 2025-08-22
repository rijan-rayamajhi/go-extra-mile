import 'package:equatable/equatable.dart';

enum GEMCoinTransactionType {
  credit,
  debit,
}

enum GEMCoinTransactionRewardType {
  dailyReward,
  rideReward,
  productReward,
  eventReward,
  referralReward,
  otherReward,
}

class GEMCoinHistoryEntity extends Equatable {
  final String id;
  final GEMCoinTransactionType type;
  final GEMCoinTransactionRewardType rewardType;
  final int amount;
  final int? balanceAfter;
  final String reason;
  final DateTime date;

  const GEMCoinHistoryEntity({
    required this.id,
    required this.type,
    required this.rewardType,
    required this.amount,
    this.balanceAfter,
    required this.reason,
    required this.date,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        rewardType,
        amount,
        balanceAfter,
        reason,
        date,
      ];

  GEMCoinHistoryEntity copyWith({
    String? id,
    GEMCoinTransactionType? type,
    GEMCoinTransactionRewardType? rewardType,
    int? amount,
    int? balanceAfter, //this is the wallet balance after the transaction
    String? reason,
    DateTime? date,
  }) {
    return GEMCoinHistoryEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      rewardType: rewardType ?? this.rewardType,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter,
      reason: reason ?? this.reason,
      date: date ?? this.date,
    );
  }
}

