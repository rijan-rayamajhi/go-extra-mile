// features/notification/presentation/bloc/notification_event.dart
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class GetNotificationDetail extends NotificationEvent {
  final String id;

  const GetNotificationDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String id;

  const MarkNotificationAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}
