import '../entities/app_settings.dart';
import '../repositories/admin_data_repository.dart';

class GetAdminData {
  final AdminDataRepository repository;

  GetAdminData(this.repository);

  Future<AppSettings> call() async {
    return await repository.getAdminData();
  }
}
