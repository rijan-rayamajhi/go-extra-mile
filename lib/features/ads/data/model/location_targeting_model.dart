import '../../domain/entities/location_targeting.dart';
import 'location_model.dart';

class LocationTargetingModel extends LocationTargeting {
  const LocationTargetingModel({
    required super.enabled,
    super.location,
    super.radius,
  });

  factory LocationTargetingModel.fromJson(Map<String, dynamic> json) {
    return LocationTargetingModel(
      enabled: json['enabled'] as bool,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      radius: json['radius'] != null
          ? (json['radius'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'location': location != null
          ? (location as LocationModel).toJson()
          : null,
      'radius': radius,
    };
  }

  factory LocationTargetingModel.fromEntity(LocationTargeting entity) {
    return LocationTargetingModel(
      enabled: entity.enabled,
      location: entity.location != null
          ? LocationModel.fromEntity(entity.location!)
          : null,
      radius: entity.radius,
    );
  }
}
