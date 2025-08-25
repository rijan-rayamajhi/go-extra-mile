// features/notification/presentation/bloc/notification_state.dart
import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationDetailLoaded extends NotificationState {
  final NotificationEntity notification;

  const NotificationDetailLoaded(this.notification);

  @override
  List<Object?> get props => [notification];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
