import 'package:equatable/equatable.dart';

enum CashoutTransactionStatus { pending, approved, rejected }

class CashoutTransactionEntity extends Equatable {
  final String id;
  final double amount;
  final int gemCoinsUsed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userUpiId;
  final String userFullName;
  final String userPhoneNumber;
  final String userWhatsAppNumber;
  final CashoutTransactionStatus status;

  const CashoutTransactionEntity({
    required this.id,
    required this.amount,
    required this.gemCoinsUsed,
    required this.createdAt,
    required this.updatedAt,
    required this.userUpiId,
    required this.userFullName,
    required this.userPhoneNumber,
    required this.userWhatsAppNumber,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    gemCoinsUsed,
    createdAt,
    updatedAt,
    userUpiId,
    userFullName,
    userPhoneNumber,
    userWhatsAppNumber,
    status,
  ];

  CashoutTransactionEntity copyWith({
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
    return CashoutTransactionEntity(
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

  // Helper methods for status checking
  bool get isPending => status == CashoutTransactionStatus.pending;
  bool get isApproved => status == CashoutTransactionStatus.approved;
  bool get isRejected => status == CashoutTransactionStatus.rejected;
}
