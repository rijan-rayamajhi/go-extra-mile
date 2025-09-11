import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:go_extra_mile_new/firebase_options.dart';
import 'package:go_extra_mile_new/core/theme/app_theme.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart' as di;
import 'package:go_extra_mile_new/core/providers/app_providers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_extra_mile_new/core/adapters/hive_adapters.dart';
 
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
        home: const AuthWrapper(),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// // Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     _initNotifications();
//   }

//   Future<void> _initNotifications() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Request permission (iOS only)
//     NotificationSettings settings = await messaging.requestPermission();

//     // Get FCM token (used to send notifications to this device)
//     token = await messaging.getToken();
//     print("FCM Token: $token");

//     // Foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Message received: ${message.notification?.title}");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Push Notification Demo")),
//       body: Center(
//         child: Text(token ?? "Fetching token..."),
//       ),
//     );
//   }
// }