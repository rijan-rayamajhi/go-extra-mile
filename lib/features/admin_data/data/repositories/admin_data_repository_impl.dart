import '../../domain/entities/app_settings.dart';
import '../../domain/entities/monetization_settings.dart';
import '../../domain/repositories/admin_data_repository.dart';
import '../datasources/admin_data_remote_datasource.dart';

class AdminDataRepositoryImpl implements AdminDataRepository {
  final AdminDataRemoteDataSource remoteDataSource;

  AdminDataRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AppSettings> getAdminData() async {
    return await remoteDataSource.getAdminData();
  }

  @override
  Future<MonetizationSettings> getMonetizationSettings() async {
    return await remoteDataSource.getMonetizationSettings();
  }
}
