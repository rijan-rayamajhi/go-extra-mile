import 'package:go_extra_mile_new/features/auth/data/datasources/user_firestore_datasource.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/account_deletion_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseAuthDataSource;
  final UserFirestoreDataSource userFirestoreDataSource;
  AuthRepositoryImpl(this.firebaseAuthDataSource, this.userFirestoreDataSource);

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final user = await firebaseAuthDataSource.signInWithGoogle();
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity?> signInWithApple() async {
    final user = await firebaseAuthDataSource.signInWithApple();
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }
 

  @override
  Future<bool> checkIfUserExists(String uid) async {
    return await userFirestoreDataSource.checkIfUserExists(uid);
  }

  @override
  Future<AccountDeletionInfo?> checkIfAccountDeleted(String uid) async {
    return await userFirestoreDataSource.checkIfAccountDeleted(uid);
  }
  
  @override
  Future<void> createNewUser(UserEntity user) {
    return userFirestoreDataSource.createUserProfile(user: user);
  }

  @override
  Future<void> signOut() {
    return firebaseAuthDataSource.signOut();
  }

  @override
  Future<void> deleteAccount(String uid, String reason) {
    return userFirestoreDataSource.deleteUserAccount(uid, reason);
  }

  @override
  Future<void> restoreAccount(String uid) {
    return userFirestoreDataSource.restoreUserAccount(uid);
  }

  @override
  Future<void> updateFCMToken(String uid) {
    return userFirestoreDataSource.updateFCMToken(uid);
  }

  @override
  Future<void> clearFCMToken(String uid) {
    return userFirestoreDataSource.clearFCMToken(uid);
  }
}
