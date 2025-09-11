abstract class ReferalRepository {
  Future<void> submitReferralCode(String referralCode);
  Future<String> getReferralCode();
  Future<Map<String, dynamic>> getMyReferalData();
}
