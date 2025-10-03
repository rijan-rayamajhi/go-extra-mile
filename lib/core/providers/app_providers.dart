import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_bloc.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/bloc/gem_coin_bloc.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_bloc.dart';
import 'package:go_extra_mile_new/features/reward/presentation/bloc/daily_reward_bloc.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/bloc/monetization_data_bloc.dart';
import 'package:go_extra_mile_new/features/bugs/presentation/bloc/bug_report_bloc.dart';
import 'package:go_extra_mile_new/features/ads/presentation/bloc/ads_bloc.dart';
import 'package:go_extra_mile_new/features/others/presentation/bloc/app_stats_bloc.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart' as di;
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_bloc.dart';

/// Core app providers widget that wraps the entire application
/// with all necessary BLoC providers for state management.
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Authentication BLoC
        BlocProvider<KAuthBloc>(create: (context) => di.sl<KAuthBloc>()),

        // Admin Data BLoC
        BlocProvider<AdminDataBloc>(
          create: (context) => di.sl<AdminDataBloc>(),
        ),

        // Profile BLoC
        BlocProvider<ProfileBloc>(create: (context) => di.sl<ProfileBloc>()),

        // Ride BLoC
        BlocProvider<RideBloc>(create: (context) => di.sl<RideBloc>()),

        // Ride Data BLoC
        BlocProvider<RideDataBloc>(create: (context) => di.sl<RideDataBloc>()),

        // Gem Coin BLoC
        BlocProvider<GemCoinBloc>(create: (context) => di.sl<GemCoinBloc>()),

        // Driving License BLoC
        BlocProvider<DrivingLicenseBloc>(
          create: (context) => di.sl<DrivingLicenseBloc>(),
        ),

        // Vehicle BLoC
        BlocProvider<VehicleBloc>(create: (context) => di.sl<VehicleBloc>()),

        // Notification BLoC
        BlocProvider<NotificationBloc>(
          create: (context) => di.sl<NotificationBloc>(),
        ),

        // Referral BLoC
        BlocProvider<ReferralBloc>(create: (context) => di.sl<ReferralBloc>()),

        // Daily Reward BLoC
        BlocProvider<DailyRewardBloc>(
          create: (context) => di.sl<DailyRewardBloc>(),
        ),

        // Monetization Data BLoC
        BlocProvider<MonetizationDataBloc>(
          create: (context) => di.sl<MonetizationDataBloc>(),
        ),

        // Bug Report BLoC
        BlocProvider<BugReportBloc>(
          create: (context) => di.sl<BugReportBloc>(),
        ),

        // Ads BLoC
        BlocProvider<AdsBloc>(create: (context) => di.sl<AdsBloc>()),

        // App Stats BLoC
        BlocProvider<AppStatsBloc>(create: (context) => di.sl<AppStatsBloc>()),
      ],
      child: child,
    );
  }
}
