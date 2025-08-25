// features/notification/presentation/bloc/notification_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import 'package:go_extra_mile_new/features/notification/domain/usecases/get_notifications.dart';
import 'package:go_extra_mile_new/features/notification/domain/usecases/get_notification_by_id.dart';
import 'package:go_extra_mile_new/features/notification/domain/usecases/mark_as_read.dart';
import 'package:go_extra_mile_new/features/notification/domain/usecases/mark_all_as_read.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final GetNotificationById getNotificationById;
  final MarkAsRead markAsRead;
  final MarkAllAsRead markAllAsRead;

  NotificationBloc({
    required this.getNotifications,
    required this.getNotificationById,
    required this.markAsRead,
    required this.markAllAsRead,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<GetNotificationDetail>(_onGetNotificationDetail);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await getNotifications();
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onGetNotificationDetail(
    GetNotificationDetail event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await getNotificationById(event.id);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notification) => emit(NotificationDetailLoaded(notification)),
    );
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAsRead(event.id);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => add(LoadNotifications()), // 🔄 reload list
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAllAsRead();
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => add(LoadNotifications()), // 🔄 reload list
    );
  }
}
