import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_event.dart';
import 'dart:io';
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
          child: Column(
            children: [
              const Spacer(),
              // App branding section
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appName,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: spacing / 2),
                    Text(
                      appDescription,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: spacing * 2),
                  ],
                ),
              ),
              Spacer(),
              // Google Sign-In button (available on all platforms)
              PrimaryButton(
                text: 'Continue with Google',
                icon: FontAwesomeIcons.google,
                onPressed: () {
                  context.read<KAuthBloc>().add(KSignInWithGoogleEvent());
                },
              ),
              const SizedBox(height: spacing),
              // Apple Sign-In button (only show on iOS)
              if (Platform.isIOS) ...[
                PrimaryButton(
                  text: 'Continue with Apple',
                  icon: FontAwesomeIcons.apple,
                  onPressed: () {
                    context.read<KAuthBloc>().add(KSignInWithAppleEvent());
                  },
                ),
                const SizedBox(height: spacing),
              ],

              //terms and conditions
              AuthTermsCondition(),
            ],
          ),
        ),
      ),
    );
  }
}
