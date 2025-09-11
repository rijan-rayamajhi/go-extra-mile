import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_reward_entity.dart';
import '../../domain/repositories/daily_reward_repository.dart';
import '../models/daily_reward_model.dart';

class DailyRewardRepositoryImpl implements DailyRewardRepository {
  final FirebaseFirestore firestore;

  DailyRewardRepositoryImpl(this.firestore);

@override
Future<DailyRewardEntity?> getUserDailyReward(String userId) async {
  final docRef = firestore.collection("daily_rewards").doc(userId);
  final doc = await docRef.get();

  if (!doc.exists) {
    // 👶 First time user → create with default values
    final now = DateTime.now();
    await docRef.set({
      "lastScratchAt": null,
      "rewardAmount": 0,
      "nextAvailableAt": now,
      "streak": 0,
    });
    return DailyRewardModel(
      lastScratchAt: null,
      rewardAmount: 0,
      nextAvailableAt: now,
      streak: 0,
    );
  }

  return DailyRewardModel.fromFirestore(doc);
}
  @override
  Future<void> updateReward(String userId, int rewardAmount) async {
    final now = DateTime.now();
    final next = now.add(const Duration(hours: 24));

    await firestore.collection("daily_rewards").doc(userId).set({
      "lastScratchAt": now,
      "rewardAmount": rewardAmount,
      "nextAvailableAt": next,
      "streak": FieldValue.increment(1),
    }, SetOptions(merge: true));
  }
}