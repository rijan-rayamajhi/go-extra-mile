import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/error/exceptions.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithGoogle,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
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

  Future<void> _onSignOut(SignOutEvent e, Emitter emit) async {
    print('AuthBloc - SignOutEvent received, emitting AuthLoading');
    emit(AuthLoading()); // Add loading state for immediate UI feedback
    print('AuthBloc - Calling authRepository.signOut()');
    await authRepository.signOut();
    print('AuthBloc - Sign out completed, emitting AuthUnauthenticated');
    emit(AuthUnauthenticated());
    print('AuthBloc - AuthUnauthenticated state emitted');
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
