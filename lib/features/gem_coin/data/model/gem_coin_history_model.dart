import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/entities/gem_coin_history_entity.dart';

class GEMCoinHistoryModel extends GEMCoinHistoryEntity {
  const GEMCoinHistoryModel({
    required super.id,
    required super.type,
    required super.rewardType,
    required super.amount,
    super.balanceAfter,
    required super.reason,
    required super.date,
  });

  /// Convert Firestore Document -> Model
  factory GEMCoinHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GEMCoinHistoryModel(
      id: doc.id,
      type: GEMCoinTransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => GEMCoinTransactionType.credit,
      ),
      rewardType: GEMCoinTransactionRewardType.values.firstWhere(
        (e) => e.toString().split('.').last == data['rewardType'],
        orElse: () => GEMCoinTransactionRewardType.otherReward,
      ),
      amount: data['amount'] ?? 0,
      balanceAfter: data['balanceAfter'],
      reason: data['reason'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  /// Convert Model -> Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last, // save enum as string
      'rewardType': rewardType.toString().split('.').last,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'reason': reason,
      'date': Timestamp.fromDate(date),
    };
  }

  /// Copy with model return type
  @override
  GEMCoinHistoryModel copyWith({
    String? id,
    GEMCoinTransactionType? type,
    GEMCoinTransactionRewardType? rewardType,
    int? amount,
    int? balanceAfter,
    String? reason,
    DateTime? date,
  }) {
    return GEMCoinHistoryModel(
      id: id ?? this.id,
      type: type ?? this.type,
      rewardType: rewardType ?? this.rewardType,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      reason: reason ?? this.reason,
      date: date ?? this.date,
    );
  }
}