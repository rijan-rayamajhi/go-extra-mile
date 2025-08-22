import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'auth_screen.dart';
import '../../../main_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Trigger authentication check when widget is created
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Debug: Print current state
        
        // Show loading while checking authentication or during logout
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 16),
                  Text('Please wait...'),
                ],
              ),
            ),
          );
        }
        
        // If authenticated, go directly to main screen
        if (state is AuthAuthenticated) {
          return const MainScreen();
        }
        
        // If not authenticated or account deleted, show auth screen
        if (state is AuthUnauthenticated) {
          return const AuthScreen();
        }
        
        // For any other state (like AuthFailure), show auth screen as fallback
        return const AuthScreen();
      },
    );
  }
} 