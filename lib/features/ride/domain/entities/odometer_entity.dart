import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'odometer_entity.g.dart';

enum OdometerVerificationStatus {
  pending,
  rejected,
  verified,
}

@HiveType(typeId: 3)
class OdometerEntity extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String? beforeRideOdometerImage;
  
  @HiveField(2)
  final DateTime? beforeRideOdometerImageCaptureAt;
  
  @HiveField(3)
  final String? afterRideOdometerImage;
  
  @HiveField(4)
  final DateTime? afterRideOdometerImageCaptureAt;
  
  @HiveField(5)
  final OdometerVerificationStatus verificationStatus;
  
  @HiveField(6)
  final String? reasons;

  const OdometerEntity({
    required this.id,
    this.beforeRideOdometerImage,
    this.beforeRideOdometerImageCaptureAt,
    this.afterRideOdometerImage,
    this.afterRideOdometerImageCaptureAt,
    this.verificationStatus = OdometerVerificationStatus.pending,
    this.reasons,
  });

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
