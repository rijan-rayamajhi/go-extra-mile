import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔔 Background handler for FCM
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationService.instance.showFCMNotification(message);
}

/// Singleton Notification Service
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  static const _fcmTokenKey = 'fcm_token';

  /// 🚀 Initialize Notifications
  Future<void> init() async {
    await _initFirebase();
    await _initLocalNotifications();
    await _initFCM();
  }

  /// ✅ Firebase Initialization
  Future<void> _initFirebase() async {
    try {
      Firebase.app();
    } catch (_) {
      await Firebase.initializeApp();
    }
  }

  /// ✅ Local Notifications Setup
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("🔔 Notification tapped → ${details.payload}");
      },
    );
  }

  /// ✅ Firebase Messaging Setup
  Future<void> _initFCM() async {
    // iOS permission request
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen(showFCMNotification);

    // App opened from terminated/background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("📲 Opened app from notification: ${message.data}");
    });

    // Token management
    await _loadToken();
    _fcmToken = await _messaging.getToken();
    if (_fcmToken != null) {
      await _saveToken(_fcmToken!);
      debugPrint("✅ FCM Token: $_fcmToken");
    }

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await _saveToken(newToken);
      debugPrint("♻️ FCM Token refreshed: $newToken");
    });
  }

  /// 🔔 Show notification from FCM
  Future<void> showFCMNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'Notifications from Firebase Cloud Messaging',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// 🔔 Manual local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'local_channel',
      'Local Notifications',
      channelDescription: 'App-only notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 📦 Token storage helpers
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString(_fcmTokenKey);
    if (_fcmToken != null) {
      debugPrint("📦 Loaded stored FCM token: $_fcmToken");
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fcmTokenKey);
    _fcmToken = null;
  }

  String? get token => _fcmToken;
}
