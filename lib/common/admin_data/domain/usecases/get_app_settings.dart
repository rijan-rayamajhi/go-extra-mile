import '../entities/app_settings.dart';
import '../repository/admin_data_repository.dart';

class GetAppSettings {
  final AdminDataRepository repository;

  GetAppSettings(this.repository);

  Future<AppSettings> call() async {
    return await repository.getAppSettings();
  }
} 