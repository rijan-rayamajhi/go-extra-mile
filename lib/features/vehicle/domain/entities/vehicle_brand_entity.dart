import 'package:equatable/equatable.dart';

enum VehicleType {
  twoWheeler('two_wheeler'),
  fourWheeler('four_wheeler'),
  twoWheelerElectric('two_wheeler_electric'),
  fourWheelerElectric('four_wheeler_electric');

  const VehicleType(this.value);
  final String value;
}

class VehicleBrandEntity extends Equatable {
  final String id;
  final String name;
  final String logoUrl;
  final VehicleType vehicleType;
  final List<String> models;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleBrandEntity({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.vehicleType,
    this.models = const [],
    this.createdAt,
    this.updatedAt,
  });

  VehicleBrandEntity copyWith({
    String? id,
    String? name,
    String? logoUrl,
    VehicleType? vehicleType,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? models,
  }) {
    return VehicleBrandEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      models: models ?? this.models,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    vehicleType,
    createdAt,
    updatedAt,
    models,
  ];
}
