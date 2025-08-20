import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;
  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final user = await dataSource.signInWithGoogle();
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = dataSource.getCurrentUser();
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }
}
