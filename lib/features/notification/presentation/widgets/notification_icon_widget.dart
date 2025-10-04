import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_state.dart';
import 'package:go_extra_mile_new/features/notification/presentation/bloc/notification_event.dart';
import 'package:go_extra_mile_new/features/notification/presentation/notification_screen.dart';

class NotificationIconWidget extends StatelessWidget {
  const NotificationIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationInitial) {
          context.read<NotificationBloc>().add(const LoadNotifications());
        } else if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NotificationLoaded) {
          // Count unread notifications
          final unreadCount = state.notifications
              .where((notification) => !notification.isRead)
              .length;

          return SafeArea(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // Notification badge
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else if (state is NotificationError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink(); // fallback
      },
    );
  }
}
