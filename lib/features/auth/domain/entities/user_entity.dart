import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? userName;

  const UserEntity({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.userName,
  });

  @override
  List<Object?> get props => [uid, displayName, email, photoUrl, userName];
}
