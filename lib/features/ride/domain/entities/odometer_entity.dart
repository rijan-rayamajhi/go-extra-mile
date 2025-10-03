import 'package:equatable/equatable.dart';

enum OdometerVerificationStatus { pending, rejected, verified }

class OdometerEntity extends Equatable {
  final String? id;
  final String? beforeRideOdometerImage;
  final DateTime? beforeRideOdometerImageCaptureAt;
  final String? afterRideOdometerImage;
  final DateTime? afterRideOdometerImageCaptureAt;
  final OdometerVerificationStatus? verificationStatus;
  final String? reasons;

  const OdometerEntity({
    this.id,
    this.beforeRideOdometerImage,
    this.beforeRideOdometerImageCaptureAt,
    this.afterRideOdometerImage,
    this.afterRideOdometerImageCaptureAt,
    this.verificationStatus,
    this.reasons,
  });

  /// 🔹 CopyWith
  OdometerEntity copyWith({
    String? id,
    String? beforeRideOdometerImage,
    DateTime? beforeRideOdometerImageCaptureAt,
    String? afterRideOdometerImage,
    DateTime? afterRideOdometerImageCaptureAt,
    OdometerVerificationStatus? verificationStatus,
    String? reasons,
  }) {
    return OdometerEntity(
      id: id ?? this.id,
      beforeRideOdometerImage:
          beforeRideOdometerImage ?? this.beforeRideOdometerImage,
      beforeRideOdometerImageCaptureAt:
          beforeRideOdometerImageCaptureAt ??
          this.beforeRideOdometerImageCaptureAt,
      afterRideOdometerImage:
          afterRideOdometerImage ?? this.afterRideOdometerImage,
      afterRideOdometerImageCaptureAt:
          afterRideOdometerImageCaptureAt ??
          this.afterRideOdometerImageCaptureAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      reasons: reasons ?? this.reasons,
    );
  }

  @override
  List<Object?> get props => [
    id,
    beforeRideOdometerImage,
    beforeRideOdometerImageCaptureAt,
    afterRideOdometerImage,
    afterRideOdometerImageCaptureAt,
    verificationStatus,
    reasons,
  ];
}
