import 'package:go_extra_mile_new/common/admin_data/domain/entities/vehicle_brand.dart';
import 'package:go_extra_mile_new/common/admin_data/domain/repository/admin_data_repository.dart';

class GetVehicleBrand {
  final AdminDataRepository repository;

  GetVehicleBrand(this.repository);

  Future<Map<String, VehicleBrand>> call() async {
    return repository.getVehicleBrands();
  }
}
