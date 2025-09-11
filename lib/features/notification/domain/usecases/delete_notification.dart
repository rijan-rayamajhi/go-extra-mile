// features/notification/domain/usecases/delete_notification.dart
import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/notification/domain/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository repository;

  DeleteNotification(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteNotification(id);
  }
}
