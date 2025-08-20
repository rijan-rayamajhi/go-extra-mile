import '../entities/app_settings.dart';
import '../entities/gem_coin.dart';
import '../entities/user_interest.dart';
import '../entities/vehicle_brand.dart';

abstract class AdminDataRepository {
  Future<AppSettings> getAppSettings();
  Future<GemCoin> getGemCoin();
  Future<UserInterestsData> getUserInterests();
  Future<Map<String, VehicleBrand>> getVehicleBrands();
  //get vechile brand by id 
  Future<VehicleBrand> getVehicleBrandById(String id);
} 