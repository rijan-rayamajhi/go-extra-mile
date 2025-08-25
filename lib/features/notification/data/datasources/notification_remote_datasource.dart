// features/notification/data/datasources/notification_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/notification/data/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> getNotificationById(String id);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _notificationCollection =>
      firestore.collection('notifications');

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final snapshot = await _notificationCollection
        .orderBy('time', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            NotificationModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
        .toList();
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    final doc = await _notificationCollection.doc(id).get();
    if (!doc.exists) throw Exception('Notification not found');
    return NotificationModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _notificationCollection.doc(id).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead() async {
    final snapshot = await _notificationCollection.get();
    final batch = firestore.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
