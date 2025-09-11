import '../repositories/auth_repository.dart';

class DeleteAccount {
  final AuthRepository authRepository;

  DeleteAccount(this.authRepository);

  Future<void> call(String uid, String reason) async {
    return await authRepository.deleteAccount(uid, reason);
  }
}
