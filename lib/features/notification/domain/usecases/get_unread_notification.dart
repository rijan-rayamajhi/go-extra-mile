// features/notification/domain/usecases/get_unread_notification.dart
import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/notification/domain/notification_repository.dart';

class GetUnreadNotification {
  final NotificationRepository repository;

  GetUnreadNotification(this.repository);

  Future<Either<Failure, String>> call() {
    return repository.getUnreadNotification();
  }
}
