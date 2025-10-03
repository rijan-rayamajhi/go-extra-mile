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
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
