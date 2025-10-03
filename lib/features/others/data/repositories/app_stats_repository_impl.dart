import '../../domain/entities/app_stats_entity.dart';
import '../../domain/repositories/app_stats_repository.dart';
import '../datasources/app_stats_firebase_datasource.dart';

class AppStatsRepositoryImpl implements AppStatsRepository {
  final AppStatsFirebaseDatasource datasource;

  AppStatsRepositoryImpl(this.datasource);

  @override
  Future<AppStatsEntity> getAppStats() async {
    return await datasource.getAppStats();
  }
}
