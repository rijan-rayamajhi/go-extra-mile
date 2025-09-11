import '../referal_repositories.dart';

class GetMyReferralData {
  final ReferalRepository repository;

  GetMyReferralData(this.repository);

  Future<Map<String, dynamic>> call() {
    return repository.getMyReferalData();
  }
}
