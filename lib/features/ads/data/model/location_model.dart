import '../../domain/entities/location.dart';

class LocationModel extends Location {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    required super.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }

  factory LocationModel.fromEntity(Location entity) {
    return LocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
    );
  }
}
