import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';

/// Failure can be a sealed class or a simple error model you define
abstract class NotificationRepository {
  /// Get all notifications
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  /// Get a single notification by ID
  Future<Either<Failure, NotificationEntity>> getNotificationById(String id);

  /// Mark a notification as read
  Future<Either<Failure, void>> markAsRead(String id);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();
}
