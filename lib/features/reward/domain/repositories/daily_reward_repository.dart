import '../entities/daily_reward_entity.dart';

abstract class DailyRewardRepository {
  Future<DailyRewardEntity?> getUserDailyReward(String userId);
  Future<void> updateReward(String userId, int rewardAmount);
}