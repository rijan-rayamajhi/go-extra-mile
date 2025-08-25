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
    on<SignInWithGoogleEvent>(
      (e, emit) => _handleSignIn(emit, () => signInWithGoogle(), provider: 'Google'),
    );
    on<SignInWithAppleEvent>(
      (e, emit) => _handleSignIn(emit, () => signInWithApple(), provider: 'Apple'),
    );
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuth);
    on<CheckReferralStatusEvent>(_onCheckReferralStatus);
  }

  /// Generic sign-in handler (Google/Apple)
  Future<void> _handleSignIn(
    Emitter<AuthState> emit,
    Future<dynamic> Function() signInMethod, {
    required String provider,
  }) async {
    log('✅ SignInWith$provider called');
    emit(AuthLoading());
    try {
      final user = await signInMethod();
      log('✅ $provider user: $user');

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (err) {
      log('❌ $provider Sign-In failed: $err');
      emit(AuthFailure(
        err is AccountDeletedException ? err.message : err.toString(),
      ));
    }
  }

  /// Handle sign-out
  Future<void> _onSignOut(SignOutEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  /// Check current auth status
  Future<void> _onCheckAuth(CheckAuthStatusEvent e, Emitter<AuthState> emit) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (err) {
      emit(AuthFailure('Failed to check authentication status: $err'));
    }
  }

  /// Check referral status
  Future<void> _onCheckReferralStatus(CheckReferralStatusEvent e, Emitter<AuthState> emit) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        // TODO: Add referral status check 
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (err) {
      emit(AuthFailure('Failed to check referral status: $err'));
    }
  }
}
