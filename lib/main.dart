import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:go_extra_mile_new/firebase_options.dart';
import 'package:go_extra_mile_new/core/theme/app_theme.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart' as di;
import 'package:go_extra_mile_new/core/providers/app_providers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_extra_mile_new/core/adapters/hive_adapters.dart';
import 'package:go_extra_mile_new/core/service/local_notification_service.dart';
import 'package:go_extra_mile_new/core/service/fcm_notification_service.dart';
import 'package:go_extra_mile_new/core/service/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  await Hive.initFlutter();

  // Register Hive type adapters
  HiveAdapters.registerAdapters();

  // Initialize notification services
  await LocalNotificationService.initialize();
  await FCMNotificationService.initialize();

  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GEM NEW',
        theme: AppTheme.lightTheme, // Follows system theme preference
        navigatorKey: NavigationService.navigatorKey,
        home: const AuthWrapper(),
      ),
    );
  }
}