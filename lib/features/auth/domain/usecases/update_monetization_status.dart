import '../repositories/auth_repository.dart';

class UpdateMonetizationStatus {
  final AuthRepository repository;

  UpdateMonetizationStatus(this.repository);

  Future<void> call(String uid, bool isMonetized) async {
    return await repository.updateMonetizationStatus(uid, isMonetized);
  }
}
