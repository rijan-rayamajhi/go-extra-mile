import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'navigation_service.dart';

class FCMNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permissions (iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token with proper error handling
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _getFCMToken();
    }

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Background/terminated message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification: ${message.notification?.title}');
      _handleMessageTap(message);
    });

    // Handle background messages when app is terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _getFCMToken() async {
    try {
      // Try to get FCM token
      String? token = await _fcm.getToken();
      debugPrint("FCM Token: $token"); // Send this to your server
      
      // You can store this token or send it to your backend
      if (token != null) {
        // TODO: Send token to your server
        // await _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      
      // If it's an APNS token error, wait a bit and try again
      if (e.toString().contains('apns-token-not-set')) {
        debugPrint('APNS token not ready, retrying in 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));
        try {
          String? token = await _fcm.getToken();
          debugPrint("FCM Token (retry): $token");
          
          if (token != null) {
            // TODO: Send token to your server
            // await _sendTokenToServer(token);
          }
        } catch (retryError) {
          debugPrint('Retry failed: $retryError');
        }
      }
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Handling foreground message: ${message.notification?.title}');
    
    // Handle foreground message logic here
    // You might want to show a local notification or update UI
    if (message.notification != null) {
      // Show local notification or update UI
      debugPrint('Notification data: ${message.notification?.body}');
    }
  }

  static void _handleMessageTap(RemoteMessage message) {
    debugPrint('Handling message tap: ${message.notification?.title}');
    
    // Handle navigation when user taps notification
    if (message.data.isNotEmpty) {
      debugPrint('Message data: ${message.data}');
      NavigationService.handleNotificationNavigation(message.data);
    } else {
      // If no data, navigate to home
      NavigationService.handleNotificationNavigation({'type': 'home'});
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  // Background message handler (must be top-level function)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Handling background message: ${message.notification?.title}');
    
    // Handle background message logic here
    // Note: This runs in a separate isolate, so you can't access UI
    if (message.notification != null) {
      debugPrint('Background notification: ${message.notification?.body}');
    }
    
    // Store notification data for when app is opened
    if (message.data.isNotEmpty) {
      NavigationService.handleTerminatedAppNotification(message.data);
    }
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FCMNotificationService._firebaseMessagingBackgroundHandler(message);
}
