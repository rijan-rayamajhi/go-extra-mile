import '../repositories/daily_reward_repository.dart';
import '../entities/daily_reward_entity.dart';

class GetUserDailyReward {
  final DailyRewardRepository repository;
  
  GetUserDailyReward(this.repository);

  Future<DailyRewardEntity?> call(String userId) async {
    return await repository.getUserDailyReward(userId);
  }
}
