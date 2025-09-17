import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/features/main_screen.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_vehicle_screen.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/screens/earn_gem_coin_screen.dart';
import 'package:go_extra_mile_new/features/redeem/redeem_screen.dart';
import 'package:go_extra_mile_new/features/notification/presentation/notification_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a specific screen based on notification data
  static Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final String? type = data['type'];
    final String? screen = data['screen'];
    final String? id = data['id'];

    debugPrint('NavigationService: Handling notification navigation');
    debugPrint('Type: $type, Screen: $screen, ID: $id');

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('NavigationService: User not authenticated, staying on auth screen');
      return;
    }

    // Navigate based on notification type or screen parameter
    switch (type?.toLowerCase()) {
      case 'ride':
        _navigateToRide(context);
        break;
      case 'profile':
        _navigateToProfile(context);
        break;
      case 'gem_coin':
      case 'earn':
        _navigateToEarnGemCoin(context);
        break;
      case 'redeem':
        _navigateToRedeem(context);
        break;
      case 'notification':
        _navigateToNotifications(context, id);
        break;
      case 'home':
        _navigateToHome(context);
        break;
      default:
        // Try to navigate based on screen parameter
        _navigateByScreen(context, screen, id);
    }
  }

  /// Navigate to ride screen
  static void _navigateToRide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RideVehicleScreen()),
    );
  }

  /// Navigate to profile screen
  static void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyProfileScreen()),
    );
  }

  /// Navigate to earn gem coin screen
  static void _navigateToEarnGemCoin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EarnGemCoinScreen()),
    );
  }

  /// Navigate to redeem screen
  static void _navigateToRedeem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RedeemScreen()),
    );
  }

  /// Navigate to notifications screen
  static void _navigateToNotifications(BuildContext context, String? notificationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          initialNotificationId: notificationId,
        ),
      ),
    );
  }

  /// Navigate to home screen (main screen with home tab selected)
  static void _navigateToHome(BuildContext context) {
    // Navigate to main screen and ensure home tab is selected
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  /// Navigate based on screen parameter
  static void _navigateByScreen(BuildContext context, String? screen, String? id) {
    switch (screen?.toLowerCase()) {
      case 'ride':
        _navigateToRide(context);
        break;
      case 'profile':
        _navigateToProfile(context);
        break;
      case 'earn':
      case 'gem_coin':
        _navigateToEarnGemCoin(context);
        break;
      case 'redeem':
        _navigateToRedeem(context);
        break;
      case 'notifications':
        _navigateToNotifications(context, id);
        break;
      case 'home':
        _navigateToHome(context);
        break;
      default:
        // Default to home if no specific screen is provided
        _navigateToHome(context);
    }
  }

  /// Handle notification click when app is terminated
  static Future<void> handleTerminatedAppNotification(Map<String, dynamic> data) async {
    debugPrint('NavigationService: Handling terminated app notification');
    debugPrint('Data: $data');
    
    // Store the notification data to be handled when app starts
    // This will be processed in the main app initialization
    _pendingNotificationData = data;
  }

  /// Get pending notification data (for terminated app notifications)
  static Map<String, dynamic>? _pendingNotificationData;
  
  static Map<String, dynamic>? getPendingNotificationData() {
    final data = _pendingNotificationData;
    _pendingNotificationData = null; // Clear after reading
    return data;
  }

  /// Check if there's pending notification data
  static bool hasPendingNotification() {
    return _pendingNotificationData != null;
  }
}
