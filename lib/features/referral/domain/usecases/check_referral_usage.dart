import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/referral_repository.dart';

class CheckReferralUsage {
  final ReferralRepository repository;

  CheckReferralUsage(this.repository);

  Future<Either<Failure, bool>> call(String userId) {
    return repository.hasUsedReferral(userId);
  }
} 