import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_reward_entity.dart';

class DailyRewardModel extends DailyRewardEntity {
  const DailyRewardModel({
    super.lastScratchAt,
    required super.rewardAmount,
    required super.nextAvailableAt,
    required super.streak,
  });

  factory DailyRewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyRewardModel(
      lastScratchAt: data['lastScratchAt'] != null
          ? (data['lastScratchAt'] as Timestamp).toDate()
          : null,
      rewardAmount: data['rewardAmount'] ?? 0,
      nextAvailableAt: (data['nextAvailableAt'] as Timestamp).toDate(),
      streak: data['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "lastScratchAt": lastScratchAt,
      "rewardAmount": rewardAmount,
      "nextAvailableAt": nextAvailableAt,
      "streak": streak,
    };
  }
}