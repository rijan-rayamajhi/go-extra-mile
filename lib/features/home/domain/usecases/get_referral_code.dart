import '../home_repositories.dart';

class GetReferralCodeUseCase {
  final HomeRepository repository;

  GetReferralCodeUseCase(this.repository);

  Future<String> call() async {
    return await repository.getReferralCode();
  }
}
