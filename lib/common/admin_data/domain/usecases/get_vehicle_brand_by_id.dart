

import 'package:go_extra_mile_new/common/admin_data/domain/entities/vehicle_brand.dart';
import 'package:go_extra_mile_new/common/admin_data/domain/repository/admin_data_repository.dart';

class GetVehicleBrandById {
  final AdminDataRepository repository;

  GetVehicleBrandById(this.repository);

  Future<VehicleBrand> call(String id) async {
    return repository.getVehicleBrandById(id);
  }
} 