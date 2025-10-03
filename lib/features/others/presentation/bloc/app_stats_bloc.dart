import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_app_stats.dart';
import 'app_stats_event.dart';
import 'app_stats_state.dart';

class AppStatsBloc extends Bloc<AppStatsEvent, AppStatsState> {
  final GetAppStats getAppStats;

  AppStatsBloc({required this.getAppStats}) : super(const AppStatsInitial()) {
    on<LoadAppStats>(_onLoadAppStats);
  }

  Future<void> _onLoadAppStats(
    LoadAppStats event,
    Emitter<AppStatsState> emit,
  ) async {
    emit(const AppStatsLoading());
    
    try {
      final appStats = await getAppStats();
      emit(AppStatsLoaded(appStats));
    } catch (e) {
      emit(AppStatsError('Failed to load app statistics: ${e.toString()}'));
    }
  }
}
