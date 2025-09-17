import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/odometer_entity.dart';

part 'odometer_model.g.dart';

@HiveType(typeId: 6)
class OdometerModel extends OdometerEntity {
  const OdometerModel({
    @HiveField(0) required super.id,
    @HiveField(1) super.beforeRideOdometerImage,
    @HiveField(2) super.beforeRideOdometerImageCaptureAt,
    @HiveField(3) super.afterRideOdometerImage,
    @HiveField(4) super.afterRideOdometerImageCaptureAt,
    @HiveField(5) super.verificationStatus = OdometerVerificationStatus.pending,
    @HiveField(6) super.reasons,
  });

  /// 🔹 copyWith
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

  /// 🔹 From Firestore
  factory OdometerModel.fromFirestore(Map<String, dynamic> data) {
    // Handle verification status conversion
    OdometerVerificationStatus status = OdometerVerificationStatus.pending;
    if (data['verificationStatus'] != null) {
      switch (data['verificationStatus'] as String) {
        case 'pending':
          status = OdometerVerificationStatus.pending;
          break;
        case 'rejected':
          status = OdometerVerificationStatus.rejected;
          break;
        case 'verified':
          status = OdometerVerificationStatus.verified;
          break;
        default:
          status = OdometerVerificationStatus.pending;
      }
    }

    // Handle timestamp conversion
    DateTime? beforeCaptureAt;
    if (data['beforeRideOdometerImageCaptureAt'] != null) {
      if (data['beforeRideOdometerImageCaptureAt'] is Timestamp) {
        beforeCaptureAt = (data['beforeRideOdometerImageCaptureAt'] as Timestamp).toDate();
      } else if (data['beforeRideOdometerImageCaptureAt'] is String) {
        beforeCaptureAt = DateTime.parse(data['beforeRideOdometerImageCaptureAt'] as String);
      }
    }

    DateTime? afterCaptureAt;
    if (data['afterRideOdometerImageCaptureAt'] != null) {
      if (data['afterRideOdometerImageCaptureAt'] is Timestamp) {
        afterCaptureAt = (data['afterRideOdometerImageCaptureAt'] as Timestamp).toDate();
      } else if (data['afterRideOdometerImageCaptureAt'] is String) {
        afterCaptureAt = DateTime.parse(data['afterRideOdometerImageCaptureAt'] as String);
      }
    }

    return OdometerModel(
      id: data['id'] as String,
      beforeRideOdometerImage: data['beforeRideOdometerImage'] as String?,
      beforeRideOdometerImageCaptureAt: beforeCaptureAt,
      afterRideOdometerImage: data['afterRideOdometerImage'] as String?,
      afterRideOdometerImageCaptureAt: afterCaptureAt,
      verificationStatus: status,
      reasons: data['reasons'] as String?,
    );
  }

  /// 🔹 To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'beforeRideOdometerImage': beforeRideOdometerImage,
      'beforeRideOdometerImageCaptureAt': beforeRideOdometerImageCaptureAt != null 
          ? Timestamp.fromDate(beforeRideOdometerImageCaptureAt!) 
          : null,
      'afterRideOdometerImage': afterRideOdometerImage,
      'afterRideOdometerImageCaptureAt': afterRideOdometerImageCaptureAt != null 
          ? Timestamp.fromDate(afterRideOdometerImageCaptureAt!) 
          : null,
      'verificationStatus': verificationStatus.name,
      'reasons': reasons,
    };
  }

  /// 🔹 From JSON
  factory OdometerModel.fromJson(Map<String, dynamic> json) {
    // Handle verification status conversion
    OdometerVerificationStatus status = OdometerVerificationStatus.pending;
    if (json['verificationStatus'] != null) {
      switch (json['verificationStatus'] as String) {
        case 'pending':
          status = OdometerVerificationStatus.pending;
          break;
        case 'rejected':
          status = OdometerVerificationStatus.rejected;
          break;
        case 'verified':
          status = OdometerVerificationStatus.verified;
          break;
        default:
          status = OdometerVerificationStatus.pending;
      }
    }

    return OdometerModel(
      id: json['id'] as String,
      beforeRideOdometerImage: json['beforeRideOdometerImage'] as String?,
      beforeRideOdometerImageCaptureAt: json['beforeRideOdometerImageCaptureAt'] != null 
          ? DateTime.parse(json['beforeRideOdometerImageCaptureAt'] as String) 
          : null,
      afterRideOdometerImage: json['afterRideOdometerImage'] as String?,
      afterRideOdometerImageCaptureAt: json['afterRideOdometerImageCaptureAt'] != null 
          ? DateTime.parse(json['afterRideOdometerImageCaptureAt'] as String) 
          : null,
      verificationStatus: status,
      reasons: json['reasons'] as String?,
    );
  }

  /// 🔹 To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beforeRideOdometerImage': beforeRideOdometerImage,
      'beforeRideOdometerImageCaptureAt': beforeRideOdometerImageCaptureAt?.toIso8601String(),
      'afterRideOdometerImage': afterRideOdometerImage,
      'afterRideOdometerImageCaptureAt': afterRideOdometerImageCaptureAt?.toIso8601String(),
      'verificationStatus': verificationStatus.name,
      'reasons': reasons,
    };
  }

  /// 🔹 From Hive
  factory OdometerModel.fromHive(Map<String, dynamic> hiveData) {
    // Handle verification status conversion
    OdometerVerificationStatus status = OdometerVerificationStatus.pending;
    if (hiveData['verificationStatus'] != null) {
      switch (hiveData['verificationStatus'] as String) {
        case 'pending':
          status = OdometerVerificationStatus.pending;
          break;
        case 'rejected':
          status = OdometerVerificationStatus.rejected;
          break;
        case 'verified':
          status = OdometerVerificationStatus.verified;
          break;
        default:
          status = OdometerVerificationStatus.pending;
      }
    }

    return OdometerModel(
      id: hiveData['id'] as String,
      beforeRideOdometerImage: hiveData['beforeRideOdometerImage'] as String?,
      beforeRideOdometerImageCaptureAt: hiveData['beforeRideOdometerImageCaptureAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(hiveData['beforeRideOdometerImageCaptureAt'] as int) 
          : null,
      afterRideOdometerImage: hiveData['afterRideOdometerImage'] as String?,
      afterRideOdometerImageCaptureAt: hiveData['afterRideOdometerImageCaptureAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(hiveData['afterRideOdometerImageCaptureAt'] as int) 
          : null,
      verificationStatus: status,
      reasons: hiveData['reasons'] as String?,
    );
  }

  /// 🔹 To Hive
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'beforeRideOdometerImage': beforeRideOdometerImage,
      'beforeRideOdometerImageCaptureAt': beforeRideOdometerImageCaptureAt?.millisecondsSinceEpoch,
      'afterRideOdometerImage': afterRideOdometerImage,
      'afterRideOdometerImageCaptureAt': afterRideOdometerImageCaptureAt?.millisecondsSinceEpoch,
      'verificationStatus': verificationStatus.name,
      'reasons': reasons,
    };
  }

  /// 🔹 Mappers
  OdometerEntity toEntity() => this;

  static OdometerModel fromEntity(OdometerEntity entity) => OdometerModel(
        id: entity.id,
        beforeRideOdometerImage: entity.beforeRideOdometerImage,
        beforeRideOdometerImageCaptureAt: entity.beforeRideOdometerImageCaptureAt,
        afterRideOdometerImage: entity.afterRideOdometerImage,
        afterRideOdometerImageCaptureAt: entity.afterRideOdometerImageCaptureAt,
        verificationStatus: entity.verificationStatus,
        reasons: entity.reasons,
      );
}
