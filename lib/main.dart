import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/core/theme/app_theme.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart' as di;
import 'firebase_options_env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: '.env.prod');
  await Firebase.initializeApp(
    options: FirebaseOptionsEnv.currentPlatform,
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
      ],
      child: MaterialApp(
        title: 'Go Extra Mile',
        theme: AppTheme.lightTheme, // Follows system theme preference
        home: const AuthWrapper(),
      ),
    );
  }
}


