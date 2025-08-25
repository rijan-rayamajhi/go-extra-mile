import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/check_referral_usage.dart';
import '../../domain/usecases/process_referral.dart';
import '../../domain/usecases/validate_referral_code.dart';
import 'referral_event.dart';
import 'referral_state.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final ValidateReferralCode validateReferralCode;
  final CheckReferralUsage checkReferralUsage;
  final ProcessReferral processReferral;

  ReferralBloc({
    required this.validateReferralCode,
    required this.checkReferralUsage,
    required this.processReferral,
  }) : super(const ReferralInitial()) {
    on<SubmitReferralCode>(_onSubmitReferralCode);
    on<SkipReferral>(_onSkipReferral);
  }

  Future<void> _onSubmitReferralCode(
    SubmitReferralCode event,
    Emitter<ReferralState> emit,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      emit(const ReferralError('User not authenticated'));
      return;
    }

    emit(const ReferralLoading());

    try {
      // Check if user has already used a referral code
      final hasUsedResult = await checkReferralUsage(currentUserId);
      
      await hasUsedResult.fold(
        (failure) {
          emit(ReferralError(failure.message));
        },
        (hasUsed) async {
          if (hasUsed) {
            emit(const ReferralError('You have already used a referral code'));
            return;
          }

          final referralCode = event.referralCode.trim();
          
          // Validate the referral code
          final validationResult = await validateReferralCode(referralCode);
          
          await validationResult.fold(
            (failure) {
              emit(ReferralError(failure.message));
            },
            (referrerUserId) async {
              if (referrerUserId == currentUserId) {
                emit(const ReferralError('You cannot use your own referral code'));
                return;
              }

              // Process the referral rewards
              final params = ProcessReferralParams(
                referrerUserId: referrerUserId,
                referredUserId: currentUserId,
                referralCode: referralCode,
              );
              
              final rewardResult = await processReferral(params);

              await rewardResult.fold(
                (failure) {
                  emit(ReferralError(failure.message));
                },
                (_) {
                  emit(const ReferralSuccess(coinsEarned: 100));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(ReferralError(e.toString()));
    }
  }

  void _onSkipReferral(
    SkipReferral event,
    Emitter<ReferralState> emit,
  ) {
    emit(const ReferralSkipped());
  }
} 