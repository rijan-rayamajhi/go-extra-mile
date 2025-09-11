import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/bloc/gem_coin_bloc.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_bloc.dart';
import 'package:go_extra_mile_new/features/home/presentation/bloc/home_bloc.dart';
import 'package:go_extra_mile_new/features/reward/presentation/bloc/daily_reward_bloc.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart' as di;

/// Core app providers widget that wraps the entire application
/// with all necessary BLoC providers for state management.
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Authentication BLoC
        BlocProvider<KAuthBloc>(
          create: (context) => di.sl<KAuthBloc>(),
        ),
        
        // Profile BLoC
        BlocProvider<ProfileBloc>(
          create: (context) => di.sl<ProfileBloc>(),
        ),
        
        // Ride BLoC
        BlocProvider<RideBloc>(
          create: (context) => di.sl<RideBloc>(),
        ),
        
        // Gem Coin BLoC
        BlocProvider<GemCoinBloc>(
          create: (context) => di.sl<GemCoinBloc>(),
        ),
        
        // Driving License BLoC
        BlocProvider<DrivingLicenseBloc>(
          create: (context) => di.sl<DrivingLicenseBloc>(),
        ),
        
        // Vehicle BLoC
        BlocProvider<VehicleBloc>(
          create: (context) => di.sl<VehicleBloc>(),
        ),
        
        // Notification BLoC
        BlocProvider<NotificationBloc>(
          create: (context) => di.sl<NotificationBloc>(),
        ),
        
        // Referral BLoC
        BlocProvider<ReferralBloc>(
          create: (context) => di.sl<ReferralBloc>(),
        ),
        
        // Home BLoC
        BlocProvider<HomeBloc>(
          create: (context) => di.sl<HomeBloc>(),
        ),
        
        // Daily Reward BLoC
        BlocProvider<DailyRewardBloc>(
          create: (context) => di.sl<DailyRewardBloc>(),
        ),
      ],
      child: child,
    );
  }
}
