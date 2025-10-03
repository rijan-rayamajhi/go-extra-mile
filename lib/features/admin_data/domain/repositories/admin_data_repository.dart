import '../entities/app_settings.dart';
import '../entities/monetization_settings.dart';

abstract class AdminDataRepository {
  Future<AppSettings> getAdminData();
  Future<MonetizationSettings> getMonetizationSettings();
}
