import '../repositories/auth_repository.dart';

class ClearFCMToken {
  final AuthRepository repository;

  ClearFCMToken(this.repository);

  Future<void> call(String uid) {
    return repository.clearFCMToken(uid);
  }
}
