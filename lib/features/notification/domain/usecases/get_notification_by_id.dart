// features/notification/domain/usecases/get_notification_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';
import 'package:go_extra_mile_new/features/notification/domain/notification_repository.dart';

class GetNotificationById {
  final NotificationRepository repository;

  GetNotificationById(this.repository);

  Future<Either<Failure, NotificationEntity>> call(String id) {
    return repository.getNotificationById(id);
  }
}
