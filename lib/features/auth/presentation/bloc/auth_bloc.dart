import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/error/exceptions.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithAppleEvent>(_onSignInWithApple);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuth);
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogleEvent e, Emitter emit) async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogle();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (err) {
      if (err is AccountDeletedException) {
        emit(AuthFailure(err.message));
      } else {
        emit(AuthFailure(err.toString()));
      }
    }
  }

  Future<void> _onSignInWithApple(SignInWithAppleEvent e, Emitter emit) async {
    log(' ✅ SignInWithAppleEvent called ');
    emit(AuthLoading());
    try {
      final user = await signInWithApple();
      log(' ✅ user: $user ');
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onSignOut(SignOutEvent e, Emitter emit) async {
    emit(AuthLoading()); // Add loading state for immediate UI feedback
    await authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuth(CheckAuthStatusEvent e, Emitter emit) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        // Check if this user account was deleted using email
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (err) {
      emit(AuthFailure('Failed to check authentication status: ${err.toString()}'));
    }
  }
}
