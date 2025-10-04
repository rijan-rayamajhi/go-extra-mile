import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_bar_widget.dart';
import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_event.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_state.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final String? initialNotificationId;

  const NotificationScreen({super.key, this.initialNotificationId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen initializes
    debugPrint('Loading notifications for current user');
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBarWidget(
        title: 'Notifications',
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded &&
                  state.notifications.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(right: baseScreenPadding),
                  child: IconButton(
                    onPressed: () {
                      debugPrint('Marking all notifications as read');
                      context.read<NotificationBloc>().add(
                        const MarkAllNotificationsAsRead(),
                      );
                    },
                    icon: Icon(
                      Icons.done_all,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Mark all as read',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(baseButtonRadius),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.colorScheme.surface,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is NotificationError) {
              // Print error for debugging
              debugPrint('Notification Error: ${state.message}');

              return Padding(
                padding: const EdgeInsets.all(baseScreenPadding),
                child: Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(baseLargeSpacing),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(baseCardRadius),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: baseXLargeIconSize,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: baseLargeSpacing),
                    Text(
                      'Error loading notifications',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: baseSpacing),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: baseLargeSpacing),
                    SizedBox(
                      width: double.infinity,
                      height: baseButtonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          debugPrint('Retrying to load notifications');
                          context.read<NotificationBloc>().add(
                            const LoadNotifications(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(baseButtonRadius),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(baseScreenPadding),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(baseLargeSpacing),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(baseCardRadius),
                          ),
                          child: Icon(
                            Icons.notifications_none_outlined,
                            size: baseXLargeIconSize,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: baseLargeSpacing),
                        Text(
                          'No notifications yet',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: baseSpacing),
                        Text(
                          'We\'ll notify you when something important happens',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  baseScreenPadding,
                  baseSpacing,
                  baseScreenPadding,
                  baseScreenPadding,
                ),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: baseSpacing),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];

                  return Dismissible(
                    key: ValueKey(notification.id),
                    direction: DismissDirection.horizontal,
                    background: _slideBackground(
                      icon: Icons.done_all,
                      text: "Mark as Read",
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                    ),
                    secondaryBackground: _slideBackground(
                      icon: Icons.delete_outline,
                      text: "Delete",
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // Slide right → mark as read
                        debugPrint(
                          'Swipe right - Marking notification as read: ${notification.id}',
                        );
                        if (!notification.isRead) {
                          context.read<NotificationBloc>().add(
                            MarkNotificationAsRead(notification.id),
                          );
                        }
                        return false; // don't remove, just update
                      } else {
                        // Slide left → delete notification
                        debugPrint(
                          'Swipe left - Deleting notification: ${notification.id}',
                        );
                        context.read<NotificationBloc>().add(
                          DeleteNotification(notification.id),
                        );
                        return true; // remove from list
                      }
                    },
                    child: _buildNotificationCard(notification),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Modern notification card
  Widget _buildNotificationCard(NotificationEntity notification) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(baseScreenPadding),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? theme.colorScheme.surface
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(baseCardRadius),
        border: Border.all(
          color: notification.isRead
              ? theme.colorScheme.outline.withOpacity(0.2)
              : theme.colorScheme.primary.withOpacity(0.3),
          width: notification.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification icon
          Container(
            padding: const EdgeInsets.all(baseCardPadding),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? theme.colorScheme.outline.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(baseCardRadius),
            ),
            child: Icon(
              notification.isRead
                  ? Icons.notifications_none_outlined
                  : Icons.notifications_active_outlined,
              color: notification.isRead
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary,
              size: baseMediumIconSize,
            ),
          ),
          const SizedBox(width: baseSpacing),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and timestamp row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: baseSmallSpacing),
                    Text(
                      DateFormat('MMM d').format(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: baseSmallSpacing),
                // Message
                Text(
                  notification.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: baseSmallSpacing),
                // Time
                Text(
                  DateFormat('h:mm a').format(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // Unread indicator
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  /// Slide background for swipe actions
  Widget _slideBackground({
    required IconData icon,
    required String text,
    required Color color,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(baseButtonRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ] else ...[
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 26),
          ],
        ],
      ),
    );
  }
}
