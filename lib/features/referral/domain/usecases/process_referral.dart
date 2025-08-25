import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/referral_repository.dart';

class ProcessReferralParams {
  final String referrerUserId;
  final String referredUserId;
  final String referralCode;

  ProcessReferralParams({
    required this.referrerUserId,
    required this.referredUserId,
    required this.referralCode,
  });
}

class ProcessReferral {
  final ReferralRepository repository;

  ProcessReferral(this.repository);

  Future<Either<Failure, void>> call(ProcessReferralParams params) {
    return repository.processReferralReward(
      referrerUserId: params.referrerUserId,
      referredUserId: params.referredUserId,
      referralCode: params.referralCode,
    );
  }
} 