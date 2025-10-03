import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_brand_entity.dart';

class VehicleBrandModel extends VehicleBrandEntity {
  const VehicleBrandModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.vehicleType,
    super.createdAt,
    super.updatedAt,
    super.models = const [],
  });

  /// Convert Firestore document to VehicleBrandModel
  factory VehicleBrandModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleBrandModel(
      id: doc.id, // Firebase doc id
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      vehicleType: _parseVehicleType(data['vehicleType']),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      models: _parseModels(data['models']),
    );
  }

  /// Convert VehicleBrandModel to JSON for Firestore
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'vehicleType': vehicleType.value,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'models': models,
    };
  }

  /// Helper: parse timestamp from Firestore data
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return null;
    }

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }

    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return null; // Fallback
  }

  /// Helper: parse vehicle type from Firestore data
  static VehicleType _parseVehicleType(dynamic vehicleType) {
    if (vehicleType == null) {
      return VehicleType.twoWheeler; // Default
    }

    if (vehicleType is String) {
      switch (vehicleType) {
        case 'two_wheeler':
          return VehicleType.twoWheeler;
        case 'four_wheeler':
          return VehicleType.fourWheeler;
        case 'two_wheeler_electric':
          return VehicleType.twoWheelerElectric;
        case 'four_wheeler_electric':
          return VehicleType.fourWheelerElectric;
        default:
          return VehicleType.twoWheeler; // Default fallback
      }
    }

    return VehicleType.twoWheeler; // Fallback
  }

  /// Helper: parse models list from Firestore data
  static List<String> _parseModels(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }
}
