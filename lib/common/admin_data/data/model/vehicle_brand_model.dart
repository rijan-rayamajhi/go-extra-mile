import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vehicle_brand.dart';

class VehicleBrandModel extends VehicleBrand {
  VehicleBrandModel({
    required super.id,
    required super.name,
    required super.status,
    required super.vehicleType,
    required super.description,
    required super.logoUrl,
    required super.models,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VehicleBrandModel.fromJson(Map<String, dynamic> json) {
    return VehicleBrandModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      models: (json['models'] as List<dynamic>?)
          ?.map((modelJson) => VehicleModelModel.fromJson(modelJson))
          .toList() ?? [],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'vehicleType': vehicleType,
      'description': description,
      'logoUrl': logoUrl,
      'models': models.map((model) => (model as VehicleModelModel).toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class VehicleModelModel extends VehicleModel {
  VehicleModelModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory VehicleModelModel.fromJson(Map<String, dynamic> json) {
    return VehicleModelModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
