import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class CreateNewUser {
  final AuthRepository repository;
  CreateNewUser(this.repository);

  Future<void> call(UserEntity user) async {
    return await repository.createNewUser(user);
  }
}
