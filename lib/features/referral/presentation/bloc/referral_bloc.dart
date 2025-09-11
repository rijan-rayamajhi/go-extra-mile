import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/referral/domain/usecases/submit_referral_code.dart';
import 'package:go_extra_mile_new/features/referral/domain/usecases/get_my_referral_data.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_event.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_state.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final SubmitReferralCode _submitReferralCode;
  final GetMyReferralData _getMyReferralData;

  ReferralBloc({
    required SubmitReferralCode submitReferralCode,
    required GetMyReferralData getMyReferralData,
  }) : _submitReferralCode = submitReferralCode,
       _getMyReferralData = getMyReferralData,
       super(ReferralInitial()) {
    on<SubmitReferralCodeEvent>(_onSubmitReferralCode);
    on<GetReferralDataEvent>(_onGetReferralData);
    on<ResetReferralEvent>(_onResetReferral);
  }

  Future<void> _onSubmitReferralCode(
    SubmitReferralCodeEvent event,
    Emitter<ReferralState> emit,
  ) async {
    try {
      emit(ReferralLoading());

      await _submitReferralCode(event.referralCode);

      emit(const ReferralSuccess());
    } catch (e) {
      emit(ReferralError(e.toString()));
    }
  }

  Future<void> _onGetReferralData(
    GetReferralDataEvent event,
    Emitter<ReferralState> emit,
  ) async {
    try {
      emit(ReferralLoading());

      final users = await _getMyReferralData();

      emit(ReferralDataLoaded(users['referralCode'], users['myReferalUsers']));
    } catch (e) {
      emit(ReferralError(e.toString()));
    }
  }

  void _onResetReferral(ResetReferralEvent event, Emitter<ReferralState> emit) {
    emit(ReferralInitial());
  }
}
