import '../repositories/auth_repository.dart';

class UpdateFCMToken {
  final AuthRepository repository;

  UpdateFCMToken(this.repository);

  Future<void> call(String uid) {
    return repository.updateFCMToken(uid);
  }
}
