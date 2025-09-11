import '../repositories/daily_reward_repository.dart';

class UpdateReward {
  final DailyRewardRepository repository;
  
  UpdateReward(this.repository);

  Future<void> call(String userId, int rewardAmount) async {
    return await repository.updateReward(userId, rewardAmount);
  }
}
