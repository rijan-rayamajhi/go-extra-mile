// features/notification/data/datasources/notification_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/features/notification/data/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> getNotificationById(String id);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<String> getUnreadNotification();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  NotificationRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }
    // Get notifications from user's notifications subcollection
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();

    // Convert Firestore documents to NotificationModel objects
    final notifications = snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data(), id: doc.id))
        .toList();

    return notifications;
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    // Extract user ID from notification ID
    final parts = id.split('_');
    if (parts.length < 3) {
      throw Exception('Invalid notification ID format');
    }

    final userId = parts[0];

    // Get notification directly from user's notifications subcollection
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .get();

    if (!doc.exists) {
      throw Exception('Notification not found');
    }

    return NotificationModel.fromMap(doc.data()!, id: doc.id);
  }

  @override
  Future<void> markAsRead(String id) async {
    // Extract user ID from notification ID
    final parts = id.split('_');
    if (parts.length < 3) {
      throw Exception('Invalid notification ID format');
    }

    final userId = parts[0];

    // Update notification directly in user's notifications subcollection
    await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .update({'isRead': true, 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = firestore.batch();
    bool hasUpdates = false;

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      hasUpdates = true;
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    // The notification ID contains the user ID, so we can extract it
    // Format: {userId}_{type}_{timestamp}
    final parts = id.split('_');
    if (parts.length < 3) {
      throw Exception('Invalid notification ID format');
    }

    final userId = parts[0];

    // Delete directly from user's notifications subcollection
    await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .delete();
  }

  @override
  Future<String> getUnreadNotification() async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length.toString();
  }
}
