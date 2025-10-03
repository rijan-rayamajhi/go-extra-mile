import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/monetization/domain/entities/cashout_transaction_entity.dart';

class CashoutTransactionModel extends CashoutTransactionEntity {
  const CashoutTransactionModel({
    required super.id,
    required super.amount,
    required super.gemCoinsUsed,
    required super.createdAt,
    required super.updatedAt,
    required super.userUpiId,
    required super.userFullName,
    required super.userPhoneNumber,
    required super.userWhatsAppNumber,
    required super.status,
  });

  /// Convert Firestore Document -> Model
  factory CashoutTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CashoutTransactionModel(
      id: doc.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      gemCoinsUsed: (data['gemCoinsUsed'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      userUpiId: data['userUpiId'] ?? '',
      userFullName: data['userFullName'] ?? '',
      userPhoneNumber: data['userPhoneNumber'] ?? '',
      userWhatsAppNumber: data['userWhatsAppNumber'] ?? '',
      status: CashoutTransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => CashoutTransactionStatus.pending,
      ),
    );
  }

  /// Convert Model -> Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'gemCoinsUsed': gemCoinsUsed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userUpiId': userUpiId,
      'userFullName': userFullName,
      'userPhoneNumber': userPhoneNumber,
      'userWhatsAppNumber': userWhatsAppNumber,
      'status': status.toString().split('.').last, // save enum as string
    };
  }

  /// Copy with model return type
  @override
  CashoutTransactionModel copyWith({
    String? id,
    double? amount,
    int? gemCoinsUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userUpiId,
    String? userFullName,
    String? userPhoneNumber,
    String? userWhatsAppNumber,
    CashoutTransactionStatus? status,
  }) {
    return CashoutTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      gemCoinsUsed: gemCoinsUsed ?? this.gemCoinsUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userUpiId: userUpiId ?? this.userUpiId,
      userFullName: userFullName ?? this.userFullName,
      userPhoneNumber: userPhoneNumber ?? this.userPhoneNumber,
      userWhatsAppNumber: userWhatsAppNumber ?? this.userWhatsAppNumber,
      status: status ?? this.status,
    );
  }

  /// Create a new model with current timestamp for updates
  CashoutTransactionModel withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Factory constructor for creating new cashout transaction
  factory CashoutTransactionModel.create({
    required double amount,
    required int gemCoinsUsed,
    required String userUpiId,
    required String userFullName,
    required String userPhoneNumber,
    required String userWhatsAppNumber,
  }) {
    final now = DateTime.now();
    return CashoutTransactionModel(
      id: '', // Will be set by Firestore
      amount: amount,
      gemCoinsUsed: gemCoinsUsed,
      createdAt: now,
      updatedAt: now,
      userUpiId: userUpiId,
      userFullName: userFullName,
      userPhoneNumber: userPhoneNumber,
      userWhatsAppNumber: userWhatsAppNumber,
      status: CashoutTransactionStatus.pending,
    );
  }
}
