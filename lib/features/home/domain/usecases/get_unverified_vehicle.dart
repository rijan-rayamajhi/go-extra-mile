import 'package:go_extra_mile_new/features/home/domain/home_repositories.dart';

class GetUnverifiedVehicle {
  final HomeRepository repository;

  GetUnverifiedVehicle(this.repository);

  Future<String> call() async {
    return await repository.getUnverifiedVehicle();
  }
}
