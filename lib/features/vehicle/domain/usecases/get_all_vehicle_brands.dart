import 'package:dartz/dartz.dart';
import '../repositories/vehicle_repository.dart';
import '../entities/vehicle_brand_entity.dart';

class GetAllVehicleBrands {
  final VehicleRepository repository;

  GetAllVehicleBrands(this.repository);

  Future<Either<Exception, List<VehicleBrandEntity>>> call() async {
    return await repository.getAllVehicleBrands();
  }
}
