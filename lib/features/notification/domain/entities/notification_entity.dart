import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final String type;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, message, time, isRead, type];
}
