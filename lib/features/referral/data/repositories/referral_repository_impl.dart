import 'package:go_extra_mile_new/features/referral/domain/referal_repositories.dart';
import 'package:go_extra_mile_new/features/referral/data/datasources/referral_remote_datasource.dart';
import 'package:go_extra_mile_new/features/referral/data/models/my_referral_user_model.dart';

class ReferralRepositoryImpl implements ReferalRepository {
  final ReferralRemoteDataSource remoteDataSource;

  ReferralRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitReferralCode(String referralCode) async {
    try {
      await remoteDataSource.submitReferralCode(referralCode);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getReferralCode() async {
    return await remoteDataSource.getReferralCode();
  }
  
  @override
  Future<Map<String, dynamic>> getMyReferalData() async {
    final String referralCode = await remoteDataSource.getReferralCode();
    final List<MyReferralUserModel> models = await remoteDataSource.getMyReferalUsers();
    return {
      'referralCode': referralCode,
      'myReferalUsers': models,
    };
  }
}
