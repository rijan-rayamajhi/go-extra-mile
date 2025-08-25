// features/notification/domain/usecases/mark_as_read.dart
import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/notification/domain/notification_repository.dart';

class MarkAsRead {
  final NotificationRepository repository;

  MarkAsRead(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.markAsRead(id);
  }
}
