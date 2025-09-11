import '../referal_repositories.dart';

class SubmitReferralCode {
  final ReferalRepository repository;

  SubmitReferralCode(this.repository);

  Future<void> call(String referralCode) {
    return repository.submitReferralCode(referralCode);
  }
}
