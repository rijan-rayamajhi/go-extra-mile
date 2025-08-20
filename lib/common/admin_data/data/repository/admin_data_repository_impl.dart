import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/gem_coin.dart';
import '../../domain/entities/user_interest.dart';
import '../../domain/entities/vehicle_brand.dart';
import '../model/app_settings_model.dart';
import '../model/gem_coin_model.dart';
import '../model/user_interest_model.dart';
import '../model/vehicle_brand_model.dart';
import '../../domain/repository/admin_data_repository.dart';

class AdminDataRepositoryImpl implements AdminDataRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppSettingsModel? _settings;
  GemCoinModel? _gemCoin;
  UserInterestsDataModel? _userInterests;

  @override
  Future<AppSettings> getAppSettings() async {
    try {
      // Check if we have cached settings
      if (_settings != null) {
        return _settings!;
      }

      // Fetch from Firestore
      final doc = await _firestore.collection('admin_data').doc('app_settings').get();
      
      if (!doc.exists) {
        throw Exception('App settings document not found');
      }

      final data = doc.data()!;
      
      // Create AppSettingsModel from Firestore data
      _settings = AppSettingsModel(
        appName: data['appName'] ?? '',
        appVersion: data['appVersion'] ?? '',
        appDescription: data['appDescription'] ?? '',
        appTagline: data['appTagline'] ?? '',
        termsAndConditions: data['termsAndConditions'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        contactPhone: data['contactPhone'] ?? '',
        website: data['website'] ?? '',
        supportEmail: data['supportEmail'] ?? '',
        socialMedia: SocialMedia(
          facebook: data['socialMedia']?['facebook'] ?? '',
          twitter: data['socialMedia']?['twitter'] ?? '',
          instagram: data['socialMedia']?['instagram'] ?? '',
          linkedin: data['socialMedia']?['linkedin'] ?? '',
          youtube: data['socialMedia']?['youtube'] ?? '',
          whatsapp: data['socialMedia']?['whatsapp'] ?? '',
        ),
        lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy: data['createdBy'] ?? '',
        isActive: data['isActive'] ?? true,
        referAndEarnText: data['referAndEarnText'] ?? '',
        totalDistance: data['totalDistance'] ?? '0',
        totalGemCoins: data['totalGemCoins'] ?? '0',
        totalRides: data['totalRides'] ?? '0',
      );

      return _settings!;
    } catch (e) {
      throw Exception('Failed to fetch app settings: $e');
    }
  }

  @override
  Future<GemCoin> getGemCoin() async {
    try {
      // Check if we have cached gem coin data
      if (_gemCoin != null) {
        return _gemCoin!;
      }

      // Fetch from Firestore
      final doc = await _firestore.collection('admin_data').doc('gem_coin').get();
      
      if (!doc.exists) {
        throw Exception('Gem coin document not found');
      }

      final data = doc.data()!;
      
      // Create GemCoinModel from Firestore data with only active actions
               // Create GemCoinModel from Firestore data with only active actions
        final actionList = data['actions'] as List<dynamic>? ?? [];
        _gemCoin = GemCoinModel(
          action: actionList
              .map((actionData) => ActionModel(
                    id: actionData['id'] ?? '',
                    name: actionData['name'] ?? '',
                    coinValue: actionData['coinValue'] ?? 0,
                    description: actionData['description'] ?? '',
                    isActive: actionData['isActive'] ?? false,
                  ))
              .where((action) => action.isActive) // Only include active actions
              .toList(),
          lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        return _gemCoin!;
    } catch (e) {
      throw Exception('Failed to fetch gem coin data: $e');
    }
  }

  @override
  Future<UserInterestsData> getUserInterests() async {
    try {
      // Check if we have cached user interests data
      if (_userInterests != null) {
        return _userInterests!;
      }

      // Fetch from Firestore
      final doc = await _firestore.collection('admin_data').doc('user_interests').get();
      
      if (!doc.exists) {
        throw Exception('User interests document not found');
      }

      final data = doc.data()!;
      
      // Create UserInterestsDataModel from Firestore data
      _userInterests = UserInterestsDataModel.fromJson(data);
      return _userInterests!;
    } catch (e) {
      throw Exception('Failed to fetch user interests data: $e');
    }
  }

  @override
  Future<Map<String, VehicleBrand>> getVehicleBrands() async {
    try {
      // Fetch from Firestore
      final doc = await _firestore.collection('admin_data').doc('vehicle_brands').get();
      print('Vehicle brands data: ${doc.data()}');
      if (!doc.exists) {
        throw Exception('Vehicle brands document not found');
      }

      final data = doc.data()!;
      
      // Extract brands array from the data
      final brandsList = data['brands'] as List<dynamic>? ?? [];
      
      // Convert to Map<String, VehicleBrand> where key is brand ID
      final Map<String, VehicleBrand> brandsMap = {};
      
      for (final brandData in brandsList) {
        try {
          final brand = VehicleBrandModel.fromJson(brandData as Map<String, dynamic>);
          brandsMap[brand.id] = brand;  // Use ID as key instead of name
        } catch (e) {
          print('Error parsing brand: $e');
          // Continue with other brands if one fails
        }
      }
      
      return brandsMap;
    } catch (e) {
      throw Exception('Failed to fetch vehicle brands data: $e');
    }
  }

  @override
  Future<VehicleBrand> getVehicleBrandById(String id) async {
    try {
      // First try to get from cached brands if available
      final brandsMap = await getVehicleBrands();
      
      if (brandsMap.containsKey(id)) {
        return brandsMap[id]!;
      }
      
      // If not found in cache, throw an exception
      throw Exception('Vehicle brand with ID $id not found');
    } catch (e) {
      throw Exception('Failed to fetch vehicle brand by ID: $e');
    }
  }
} 