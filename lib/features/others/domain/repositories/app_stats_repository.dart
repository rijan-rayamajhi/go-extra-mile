import '../entities/app_stats_entity.dart';

abstract class AppStatsRepository {
  /// Fetches aggregated app statistics from all users
  Future<AppStatsEntity> getAppStats();
}
