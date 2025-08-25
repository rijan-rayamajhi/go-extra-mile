import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_extra_mile_new/firebase_options.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/bloc/gem_coin_bloc.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_bloc.dart';
import 'package:go_extra_mile_new/core/theme/app_theme.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart' as di;
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    await di.init();
  runApp(const MyApp());
}
  
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => di.sl<ProfileBloc>(),
        ),
        BlocProvider<RideBloc>(
          create: (context) => di.sl<RideBloc>(),
        ),
        BlocProvider<GemCoinBloc>(
          create: (context) => di.sl<GemCoinBloc>(),
        ),
        BlocProvider<DrivingLicenseBloc>(
          create: (context) => di.sl<DrivingLicenseBloc>(),
        ),
        BlocProvider<VehicleBloc>(
          create: (context) => di.sl<VehicleBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => di.sl<NotificationBloc>(),
        ),
        BlocProvider<ReferralBloc>(
          create: (context) => di.sl<ReferralBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GEM NEW',
        theme: AppTheme.lightTheme, // Follows system theme preference
        home: const AuthWrapper(),
      ),
    );
  }
}


