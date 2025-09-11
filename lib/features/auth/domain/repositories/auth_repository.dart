import '../../domain/entities/user_entity.dart';
import '../../domain/entities/account_deletion_info.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInWithApple();
  Future<bool> checkIfUserExists(String uid);
  Future<AccountDeletionInfo?> checkIfAccountDeleted(String uid);
  Future<void> createNewUser(UserEntity user);
  Future<void> signOut();
  Future<void> deleteAccount(String uid , String reason);
  Future<void> restoreAccount(String uid);
}
