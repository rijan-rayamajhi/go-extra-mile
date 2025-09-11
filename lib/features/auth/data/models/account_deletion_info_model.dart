import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account_deletion_info.dart';

class AccountDeletionInfoModel extends AccountDeletionInfo {
  const AccountDeletionInfoModel({
    required super.uid,
    required super.reason,
    required super.createdAt,
  });

  factory AccountDeletionInfoModel.fromFirestore(Map<String, dynamic> data) {
    final timestamp = data['createdAt'] as Timestamp?;
    
    return AccountDeletionInfoModel(
      uid: data['uid'] as String,
      reason: data['reason'] as String,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
