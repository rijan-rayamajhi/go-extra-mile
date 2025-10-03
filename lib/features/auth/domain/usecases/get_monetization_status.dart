import '../repositories/auth_repository.dart';

class GetMonetizationStatus {
  final AuthRepository repository;

  GetMonetizationStatus(this.repository);

  Future<bool> call(String uid) async {
    return await repository.getMonetizationStatus(uid);
  }
}
