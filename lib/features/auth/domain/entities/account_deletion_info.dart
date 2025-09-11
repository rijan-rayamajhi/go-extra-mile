class AccountDeletionInfo {
  final String uid;
  final String reason;
  final DateTime createdAt;

  const AccountDeletionInfo({
    required this.uid,
    required this.reason,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountDeletionInfo &&
        other.uid == uid &&
        other.reason == reason &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => uid.hashCode ^ reason.hashCode ^ createdAt.hashCode;

  @override
  String toString() {
    return 'AccountDeletionInfo(uid: $uid, reason: $reason, deletedAt: $createdAt)';
  }
}
