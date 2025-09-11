import '../repositories/auth_repository.dart';
import '../entities/account_deletion_info.dart';

class CheckIfAccountDeleted {
  final AuthRepository repository;
  CheckIfAccountDeleted(this.repository);

  Future<AccountDeletionInfo?> call(String uid) async {
    return await repository.checkIfAccountDeleted(uid);
  }
}
