import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_terms_condition.dart';

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
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
              // Note: Navigation is now handled by AuthWrapper
            },
            builder: (context, state) {
              return Column(
                children: [
                  const Spacer(),
                  // App branding section
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appName,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: spacing / 2),
                        Text(
                          appDescription,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: spacing * 2),
                      ],
                    ),
                  ),
                  Spacer(),
                  // Show both buttons only on iOS, otherwise show only Google
                  Builder(
                    builder: (context) {
                      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
                      if (isIOS) {
                        return Column(
                          children: [
                            PrimaryButton(
                              text: 'Continue with Google',
                              icon: FontAwesomeIcons.google,
                              onPressed: () {
                                context.read<AuthBloc>().add(SignInWithGoogleEvent());
                              },
                              isLoading: state is AuthLoading,
                            ),
                            const SizedBox(height: spacing),
                            PrimaryButton(
                              text: 'Continue with Apple',
                              icon: FontAwesomeIcons.apple,
                              onPressed: () {
                                context.read<AuthBloc>().add(SignInWithAppleEvent());
                              },
                              isLoading: state is AuthLoading,
                            ),
                          ],
                        );
                      } else {
                        return PrimaryButton(
                          text: 'Continue with Google',
                          icon: FontAwesomeIcons.google,
                          onPressed: () {
                            context.read<AuthBloc>().add(SignInWithGoogleEvent());
                          },
                          isLoading: state is AuthLoading,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: spacing),

                  //terms and conditions
                  AuthTermsCondition(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
