import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      debugPrint('Loading notifications for user: ${currentUser.uid}');
      context.read<NotificationBloc>().add(LoadNotifications(currentUser.uid));
    } else {
      debugPrint('No current user found - cannot load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Notifications',
        centerTitle: false,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.notifications.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      debugPrint('Marking all notifications as read for user: ${currentUser.uid}');
                      context.read<NotificationBloc>().add(MarkAllNotificationsAsRead(currentUser.uid));
                    } else {
                      debugPrint('No current user found - cannot mark all as read');
                    }
                  },
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is NotificationError) {
              // Print error for debugging
              debugPrint('Notification Error: ${state.message}');
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading notifications',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          debugPrint('Retrying to load notifications for user: ${currentUser.uid}');
                          context.read<NotificationBloc>().add(LoadNotifications(currentUser.uid));
                        } else {
                          debugPrint('No current user found - cannot retry loading notifications');
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll notify you when something important happens',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(baseScreenPadding, 0, baseScreenPadding, baseScreenPadding),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: baseSpacing),
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
                        debugPrint('Swipe right - Marking notification as read: ${notification.id}');
                        if (!notification.isRead) {
                          context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id));
                        }
                        return false; // don't remove, just update
                      } else {
                        // Slide left → delete notification
                        debugPrint('Swipe left - Deleting notification: ${notification.id}');
                        context.read<NotificationBloc>().add(DeleteNotification(notification.id));
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

  /// Glassy card
  Widget _buildNotificationCard(NotificationEntity notification) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(baseButtonRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(baseScreenPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(baseButtonRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notification.isRead 
                    ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.isRead
                    ? Icons.notifications_none_outlined
                    : Icons.notifications_active_outlined,
                color: notification.isRead 
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            title: Text(
              notification.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: notification.isRead
                    ? FontWeight.w500
                    : FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              notification.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            trailing: Text(
              DateFormat('MMM d, h:mm a').format(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
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
