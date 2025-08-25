// features/notification/domain/usecases/mark_all_as_read.dart
import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/notification/domain/notification_repository.dart';

class MarkAllAsRead {
  final NotificationRepository repository;

  MarkAllAsRead(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.markAllAsRead();
  }
}
