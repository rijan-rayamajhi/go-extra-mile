import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/referral_repository.dart';

class ValidateReferralCode {
  final ReferralRepository repository;

  ValidateReferralCode(this.repository);

  Future<Either<Failure, String>> call(String referralCode) {
    return repository.validateReferralCode(referralCode);
  }
} 