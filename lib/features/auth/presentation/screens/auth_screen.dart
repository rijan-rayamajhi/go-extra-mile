import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(screenPadding),
          child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Authentication failed: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } 
                // Note: Navigation is now handled by AuthWrapper
              },
              builder: (context, state) {
                return Column(
                  children: [
                    const Spacer(),
                    PrimaryButton(
                      text: 'Continue with Google',
                      onPressed: () {
                        context.read<AuthBloc>().add(SignInWithGoogleEvent());
                      },
                    ),
                    const SizedBox(height: spacing),
                  ],
                );
              },
            ),
          ),
        ),
      );
  }
}