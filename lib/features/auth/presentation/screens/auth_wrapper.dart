import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/screens/loading_screen.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_event.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_state.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/account_deleted_screen.dart';
import 'package:go_extra_mile_new/features/main_screen.dart';
import 'package:go_extra_mile_new/core/service/navigation_service.dart';
import 'auth_screen.dart';
import '../../../referral/presentation/screens/referral_screen.dart';

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
    context.read<KAuthBloc>().add(KCheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KAuthBloc, KAuthState>(
      listener: (context, state) {
        if (state is KAuthFailure) {
          // AppSnackBar.error(context, 'Something went wrong');
        }
        
        // Handle pending notification when user becomes authenticated
        if (state is KAuthAuthenticated && NavigationService.hasPendingNotification()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final pendingData = NavigationService.getPendingNotificationData();
            if (pendingData != null) {
              NavigationService.handleNotificationNavigation(pendingData);
            }
          });
        }
      },
      builder: (context, state) {
        if (state is KAuthInitial) {
          return const AuthScreen();
        }

        // Show loading while checking authentication or during logout
        if (state is KAuthLoading) {
          return LoadingScreen();
        }
        // Handle deleted account
        if (state is KAuthDeletedUser) {
          return const AccountDeletedScreen();
        }

        // Handle new user - redirect to referral screen
        if (state is KAuthNewUser) {
          return const ReferralScreen();
        }

        // Legacy authenticated state (fallback to main screen)
        if (state is KAuthAuthenticated) {
          return const MainScreen();
        }
        // For any other state (like AuthFailure), show auth screen as fallback
        return const AuthScreen();
      },
    );
  }
}
