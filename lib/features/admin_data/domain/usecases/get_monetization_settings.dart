import '../entities/monetization_settings.dart';
import '../repositories/admin_data_repository.dart';

class GetMonetizationSettings {
  final AdminDataRepository repository;

  GetMonetizationSettings(this.repository);

  Future<MonetizationSettings> call() async {
    return await repository.getMonetizationSettings();
  }
}
