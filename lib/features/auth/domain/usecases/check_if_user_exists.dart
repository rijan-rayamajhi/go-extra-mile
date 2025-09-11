import '../repositories/auth_repository.dart';

class CheckIfUserExists {
  final AuthRepository repository;
  CheckIfUserExists(this.repository);

  Future<bool> call(String uid) async {
    return await repository.checkIfUserExists(uid);
  }
}
