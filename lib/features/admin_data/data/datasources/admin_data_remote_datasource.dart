import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_settings_model.dart';
import '../models/monetization_settings_model.dart';

abstract class AdminDataRemoteDataSource {
  Future<AppSettingsModel> getAdminData();
  Future<MonetizationSettingsModel> getMonetizationSettings();
}

class AdminDataRemoteDataSourceImpl implements AdminDataRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminDataRemoteDataSourceImpl({required this.firestore});

  @override
  Future<AppSettingsModel> getAdminData() async {
    try {
      final doc = await firestore
          .collection('admin_data')
          .doc('app_settings')
          .get();

      if (doc.exists && doc.data() != null) {
        return AppSettingsModel.fromJson(doc.data()!);
      } else {
        throw Exception('Admin data document does not exist');
      }
    } catch (e) {
      throw Exception('Failed to fetch admin data: $e');
    }
  }

  @override
  Future<MonetizationSettingsModel> getMonetizationSettings() async {
    try {
      final doc = await firestore
          .collection('admin_data')
          .doc('monetization_settings')
          .get();

      if (doc.exists && doc.data() != null) {
        return MonetizationSettingsModel.fromJson(doc.data()!);
      } else {
        throw Exception('Monetization settings document does not exist');
      }
    } catch (e) {
      throw Exception('Failed to fetch monetization settings: $e');
    }
  }
}
