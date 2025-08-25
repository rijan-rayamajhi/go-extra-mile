import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ReferralRepository {
  /// Validates and processes a referral code
  /// Returns the referrer's user ID if successful
  Future<Either<Failure, String>> validateReferralCode(String referralCode);

  /// Updates coin balances for both users after successful referral
  Future<Either<Failure, void>> processReferralReward({
    required String referrerUserId,
    required String referredUserId,
    required String referralCode,
  });

  /// Checks if a user has already used a referral code
  Future<Either<Failure, bool>> hasUsedReferral(String userId);
} 