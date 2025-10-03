import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_event.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_bloc.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_event.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_state.dart';
import 'dart:io';
import '../widgets/auth_terms_condition.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch admin data when screen loads
    context.read<AdminDataBloc>().add(FetchAdminDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(baseScreenPadding),
          child: BlocBuilder<AdminDataBloc, AdminDataState>(
            builder: (context, state) {
              String appName = '';
              String appTagline = '';
              String termsAndConditionLink = '';

              if (state is AdminDataLoaded) {
                appName = state.appSettings.appName;
                appTagline = state.appSettings.appTagline;
                termsAndConditionLink = state.appSettings.termsAndConditionLink;
              }

              return Column(
                children: [
                  const Spacer(),
                  // App branding section
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state is AdminDataLoading)
                          const CircularProgressIndicator()
                        else
                          Text(
                            appName,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: baseSpacing / 2),
                        Text(
                          appTagline,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: baseSpacing * 2),
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
                  const SizedBox(height: baseSpacing),
                  // Apple Sign-In button (only show on iOS)
                  if (Platform.isIOS) ...[
                    PrimaryButton(
                      text: 'Continue with Apple',
                      icon: FontAwesomeIcons.apple,
                      onPressed: () {
                        context.read<KAuthBloc>().add(KSignInWithAppleEvent());
                      },
                    ),
                    const SizedBox(height: baseSpacing),
                  ],

                  //terms and conditions
                  AuthTermsCondition(
                    termsAndConditionLink: termsAndConditionLink,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
