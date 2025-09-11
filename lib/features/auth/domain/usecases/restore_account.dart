import '../repositories/auth_repository.dart';

class RestoreAccount {
  final AuthRepository authRepository;

  RestoreAccount(this.authRepository);

  Future<void> call(String uid) async {
    return await authRepository.restoreAccount(uid);
  }
}
