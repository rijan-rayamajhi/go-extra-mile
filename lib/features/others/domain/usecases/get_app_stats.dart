import '../entities/app_stats_entity.dart';
import '../repositories/app_stats_repository.dart';

class GetAppStats {
  final AppStatsRepository repository;

  GetAppStats(this.repository);

  Future<AppStatsEntity> call() async {
    return await repository.getAppStats();
  }
}
