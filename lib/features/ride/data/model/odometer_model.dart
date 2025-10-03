import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/odometer_entity.dart';

class OdometerModel extends OdometerEntity {
  const OdometerModel({
    super.id,
    super.beforeRideOdometerImage,
    super.beforeRideOdometerImageCaptureAt,
    super.afterRideOdometerImage,
    super.afterRideOdometerImageCaptureAt,
    super.verificationStatus,
    super.reasons,
  });

  factory OdometerModel.fromFirestore(Map<String, dynamic> data) {
    OdometerVerificationStatus? status;
    if (data['verificationStatus'] != null) {
      switch (data['verificationStatus'] as String) {
        case 'rejected':
          status = OdometerVerificationStatus.rejected;
          break;
        case 'verified':
          status = OdometerVerificationStatus.verified;
          break;
        case 'pending':
        default:
          status = OdometerVerificationStatus.pending;
      }
    }

    DateTime? beforeCaptureAt;
    if (data['beforeRideOdometerImageCaptureAt'] is Timestamp) {
      beforeCaptureAt = (data['beforeRideOdometerImageCaptureAt'] as Timestamp)
          .toDate();
    } else if (data['beforeRideOdometerImageCaptureAt'] is String) {
      beforeCaptureAt = DateTime.tryParse(
        data['beforeRideOdometerImageCaptureAt'],
      );
    }

    DateTime? afterCaptureAt;
    if (data['afterRideOdometerImageCaptureAt'] is Timestamp) {
      afterCaptureAt = (data['afterRideOdometerImageCaptureAt'] as Timestamp)
          .toDate();
    } else if (data['afterRideOdometerImageCaptureAt'] is String) {
      afterCaptureAt = DateTime.tryParse(
        data['afterRideOdometerImageCaptureAt'],
      );
    }

    return OdometerModel(
      id: data['id'] as String?,
      beforeRideOdometerImage: data['beforeRideOdometerImage'] as String?,
      beforeRideOdometerImageCaptureAt: beforeCaptureAt,
      afterRideOdometerImage: data['afterRideOdometerImage'] as String?,
      afterRideOdometerImageCaptureAt: afterCaptureAt,
      verificationStatus: status,
      reasons: data['reasons'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (beforeRideOdometerImage != null)
        'beforeRideOdometerImage': beforeRideOdometerImage,
      if (beforeRideOdometerImageCaptureAt != null)
        'beforeRideOdometerImageCaptureAt': Timestamp.fromDate(
          beforeRideOdometerImageCaptureAt!,
        ),
      if (afterRideOdometerImage != null)
        'afterRideOdometerImage': afterRideOdometerImage,
      if (afterRideOdometerImageCaptureAt != null)
        'afterRideOdometerImageCaptureAt': Timestamp.fromDate(
          afterRideOdometerImageCaptureAt!,
        ),
      if (verificationStatus != null)
        'verificationStatus': verificationStatus!.name,
      if (reasons != null) 'reasons': reasons,
    };
  }

  /// 🔹 Hive / JSON support
  factory OdometerModel.fromJson(Map<String, dynamic> json) {
    OdometerVerificationStatus? status;
    if (json['verificationStatus'] != null) {
      switch (json['verificationStatus'] as String) {
        case 'rejected':
          status = OdometerVerificationStatus.rejected;
          break;
        case 'verified':
          status = OdometerVerificationStatus.verified;
          break;
        case 'pending':
        default:
          status = OdometerVerificationStatus.pending;
      }
    }

    return OdometerModel(
      id: json['id'] as String?,
      beforeRideOdometerImage: json['beforeRideOdometerImage'] as String?,
      beforeRideOdometerImageCaptureAt:
          json['beforeRideOdometerImageCaptureAt'] != null
          ? DateTime.parse(json['beforeRideOdometerImageCaptureAt'])
          : null,
      afterRideOdometerImage: json['afterRideOdometerImage'] as String?,
      afterRideOdometerImageCaptureAt:
          json['afterRideOdometerImageCaptureAt'] != null
          ? DateTime.parse(json['afterRideOdometerImageCaptureAt'])
          : null,
      verificationStatus: status,
      reasons: json['reasons'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beforeRideOdometerImage': beforeRideOdometerImage,
      'beforeRideOdometerImageCaptureAt': beforeRideOdometerImageCaptureAt
          ?.toIso8601String(),
      'afterRideOdometerImage': afterRideOdometerImage,
      'afterRideOdometerImageCaptureAt': afterRideOdometerImageCaptureAt
          ?.toIso8601String(),
      'verificationStatus': verificationStatus?.name,
      'reasons': reasons,
    };
  }

  OdometerModel copyWith({
    String? id,
    String? beforeRideOdometerImage,
    DateTime? beforeRideOdometerImageCaptureAt,
    String? afterRideOdometerImage,
    DateTime? afterRideOdometerImageCaptureAt,
    OdometerVerificationStatus? verificationStatus,
    String? reasons,
  }) {
    return OdometerModel(
      id: id ?? this.id,
      beforeRideOdometerImage: beforeRideOdometerImage ?? this.beforeRideOdometerImage,
      beforeRideOdometerImageCaptureAt: beforeRideOdometerImageCaptureAt ?? this.beforeRideOdometerImageCaptureAt,
      afterRideOdometerImage: afterRideOdometerImage ?? this.afterRideOdometerImage,
      afterRideOdometerImageCaptureAt: afterRideOdometerImageCaptureAt ?? this.afterRideOdometerImageCaptureAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      reasons: reasons ?? this.reasons,
    );
  }

  static OdometerModel fromEntity(OdometerEntity? entity) {
    if (entity == null) return const OdometerModel();
    return OdometerModel(
      id: entity.id,
      beforeRideOdometerImage: entity.beforeRideOdometerImage,
      beforeRideOdometerImageCaptureAt: entity.beforeRideOdometerImageCaptureAt,
      afterRideOdometerImage: entity.afterRideOdometerImage,
      afterRideOdometerImageCaptureAt: entity.afterRideOdometerImageCaptureAt,
      verificationStatus: entity.verificationStatus,
      reasons: entity.reasons,
    );
  }
}
