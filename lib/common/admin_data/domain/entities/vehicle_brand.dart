class VehicleBrand {
  final String id;
  final String name;
  final String status;
  final String vehicleType;
  final String description;
  final String logoUrl;
  final List<VehicleModel> models;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleBrand({
    required this.id,
    required this.name,
    required this.status,
    required this.vehicleType,
    required this.description,
    required this.logoUrl,
    required this.models,
    required this.createdAt,
    required this.updatedAt,
  });


}

class VehicleModel {
  final String id;
  final String name;
  final String description;

  VehicleModel({
    required this.id,
    required this.name,
    required this.description,
  });
}
