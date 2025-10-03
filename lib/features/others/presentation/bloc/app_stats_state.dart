import '../../domain/entities/app_stats_entity.dart';

abstract class AppStatsState {
  const AppStatsState();
}

class AppStatsInitial extends AppStatsState {
  const AppStatsInitial();
}

class AppStatsLoading extends AppStatsState {
  const AppStatsLoading();
}

class AppStatsLoaded extends AppStatsState {
  final AppStatsEntity appStats;

  const AppStatsLoaded(this.appStats);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppStatsLoaded && other.appStats == appStats;
  }

  @override
  int get hashCode => appStats.hashCode;
}

class AppStatsError extends AppStatsState {
  final String message;

  const AppStatsError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppStatsError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
