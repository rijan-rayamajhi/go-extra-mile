import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/app_bar_widget.dart';
import 'package:go_extra_mile_new/features/notification/domain/entities/notification_entity.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dummy notifications
  final List<NotificationEntity> _notifications = [
    NotificationEntity(
      id: "1",
      title: "Welcome!",
      message: "Thanks for joining our app 🎉",
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      type: "Welcome",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Notifications',
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(screenPadding, 0, screenPadding, screenPadding),
          itemCount: _notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: spacing),
          itemBuilder: (context, index) {
            final notification = _notifications[index];

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
                  setState(() {
                    _notifications[index] = NotificationEntity(
                      id: notification.id,
                      title: notification.title,
                      message: notification.message,
                      time: notification.time,
                      isRead: true,
                      type: notification.type,
                    );
                  });
                  return false; // don't remove, just update
                } else {
                  // Slide left → delete
                  setState(() {
                    _notifications.removeAt(index);
                  });
                  return true; // remove from list
                }
              },
              child: _buildNotificationCard(notification),
            );
          },
        ),
      ),
    );
  }

  /// Glassy card
  Widget _buildNotificationCard(NotificationEntity notification) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(buttonRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(screenPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(buttonRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(0.9),
                Theme.of(context).colorScheme.surface.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
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
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: Text(
              DateFormat('MMM d, h:mm a').format(notification.time),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(buttonRadius),
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
