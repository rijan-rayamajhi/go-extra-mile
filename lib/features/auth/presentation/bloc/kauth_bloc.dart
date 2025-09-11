import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/check_if_account_deleted.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/check_if_user_exists.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/create_new_user.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/sign_out.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/delete_account.dart';
import 'package:go_extra_mile_new/features/auth/domain/usecases/restore_account.dart';
import 'package:go_extra_mile_new/features/auth/domain/entities/account_deletion_info.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_event.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_state.dart';

class KAuthBloc extends Bloc<KAuthEvent, KAuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;
  final CheckIfUserExists checkIfUserExists;
  final CheckIfAccountDeleted checkIfAccountDeleted;
  final CreateNewUser createNewUser;
  final SignOut signOut;
  final DeleteAccount deleteAccount;
  final RestoreAccount restoreAccount;
  KAuthBloc({
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.checkIfUserExists,
    required this.checkIfAccountDeleted,
    required this.createNewUser,
    required this.signOut,
    required this.deleteAccount,
    required this.restoreAccount,
  }) : super(KAuthInitial()) {
    on<KSignInWithGoogleEvent>(_onSignInWithGoogle);
    on<KSignInWithAppleEvent>(_onSignInWithApple);
    on<KSignOutEvent>(_onSignOut);
    on<KDeleteAccountEvent>(_onDeleteAccount);
    on<KRestoreAccountEvent>(_onRestoreAccount);
    on<KCheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithGoogle(
    KSignInWithGoogleEvent event,
    Emitter<KAuthState> emit,
  ) async {
    emit(KAuthLoading());
    try {
      final user = await signInWithGoogle();

      final userExists = await checkIfUserExists(user!.uid);
      AccountDeletionInfo? accountDeletedInfo;
      try {
        accountDeletedInfo = await checkIfAccountDeleted(user.uid);
      } catch (e) {
        // Continue without account deletion check if it fails
        accountDeletedInfo = null;
      }

      if (userExists) {
        if (accountDeletedInfo != null) {
          emit(KAuthDeletedUser(accountDeletedInfo));
        } else {
          emit(KAuthAuthenticated());
        }
      } else {
        await createNewUser(user);
        emit(KAuthNewUser());
      }
    } catch (e) {
      emit(KAuthFailure(e.toString()));
    }
  }

  Future<void> _onSignInWithApple(
    KSignInWithAppleEvent event,
    Emitter<KAuthState> emit,
  ) async {
    emit(KAuthLoading());
    try {
      final user = await signInWithApple();

      final userExists = await checkIfUserExists(user!.uid);
      AccountDeletionInfo? accountDeletedInfo;
      try {
        accountDeletedInfo = await checkIfAccountDeleted(user.uid);
      } catch (e) {
        // Continue without account deletion check if it fails
        accountDeletedInfo = null;
      }

      if (userExists) {
        if (accountDeletedInfo != null) {
          emit(KAuthDeletedUser(accountDeletedInfo));
        } else {
          emit(KAuthAuthenticated());
        }
      } else {
        await createNewUser(user);
        emit(KAuthNewUser());
      }
    } catch (e) {
      emit(KAuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOut(KSignOutEvent event, Emitter<KAuthState> emit) async {
    emit(KAuthLoading());
    try {
      await signOut();
      emit(KAuthInitial());
    } catch (e) {
      emit(KAuthFailure(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    KDeleteAccountEvent event,
    Emitter<KAuthState> emit,
  ) async {
    emit(KAuthLoading());
    try {
      await deleteAccount(event.uid, event.reason);
      await signOut();
      emit(KAuthInitial());
    } catch (e) {
      emit(KAuthFailure(e.toString()));
    }
  }

  Future<void> _onRestoreAccount(
    KRestoreAccountEvent event,
    Emitter<KAuthState> emit,
  ) async {
    emit(KAuthLoading());
    try {
      await restoreAccount(event.uid);
      await signOut();
      emit(KAuthInitial());
    } catch (e) {
      emit(KAuthFailure(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    KCheckAuthStatusEvent event,
    Emitter<KAuthState> emit,
  ) async {
    emit(KAuthLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(KAuthInitial());
      } else {
        // Check if user exists in Firestore
        final userExists = await checkIfUserExists(user.uid);

        if (userExists) {
          // Check if account is deleted
          AccountDeletionInfo? accountDeletedInfo;
          try {
            accountDeletedInfo = await checkIfAccountDeleted(user.uid);
          } catch (e) {
            // Continue without account deletion check if it fails
            accountDeletedInfo = null;
          }

          if (accountDeletedInfo != null) {
            emit(KAuthDeletedUser(accountDeletedInfo));
          } else {
            emit(KAuthAuthenticated());
          }
        }
      }
    } catch (e) {
      emit(KAuthFailure(e.toString()));
    }
  }
}
