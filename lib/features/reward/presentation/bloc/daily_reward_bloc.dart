import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/reward/domain/usecases/get_user_daily_reward.dart';
import 'package:go_extra_mile_new/features/reward/domain/usecases/update_reward.dart';
import 'package:go_extra_mile_new/features/reward/presentation/bloc/daily_reward_event.dart';
import 'package:go_extra_mile_new/features/reward/presentation/bloc/daily_reward_state.dart';

class DailyRewardBloc extends Bloc<DailyRewardEvent, DailyRewardState> {
  final GetUserDailyReward _getUserDailyReward;
  final UpdateReward _updateReward;

  DailyRewardBloc({
    required GetUserDailyReward getUserDailyReward,
    required UpdateReward updateReward,
  })  : _getUserDailyReward = getUserDailyReward,
        _updateReward = updateReward,
        super(DailyRewardInitial()) {
    on<GetDailyRewardEvent>(_onGetDailyReward);
    on<UpdateRewardEvent>(_onUpdateReward);
  }

  Future<void> _onGetDailyReward(
    GetDailyRewardEvent event,
    Emitter<DailyRewardState> emit,
  ) async {
    try {
      emit(DailyRewardLoading());
      
      final dailyReward = await _getUserDailyReward(event.userId);
        emit(DailyRewardLoaded(dailyReward!));
    } catch (e) {
      emit(DailyRewardError(e.toString()));
    }
  }

  Future<void> _onUpdateReward(
    UpdateRewardEvent event,
    Emitter<DailyRewardState> emit,
  ) async {
    try {
      await _updateReward(event.userId, event.rewardAmount);
    } catch (e) {
      emit(DailyRewardError(e.toString()));
    }
  }
}
