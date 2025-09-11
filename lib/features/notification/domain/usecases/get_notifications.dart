// features/notification/domain/usecases/get_notifications.dart
import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';
import 'package:go_extra_mile_new/features/notification/domain/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(String userId) {
    return repository.getNotifications(userId);
  }
}
