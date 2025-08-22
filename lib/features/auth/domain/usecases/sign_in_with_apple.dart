import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class SignInWithApple {
  final AuthRepository repository;
  SignInWithApple(this.repository);

  Future<UserEntity?> call() async {
    return await repository.signInWithApple();
  }
}
