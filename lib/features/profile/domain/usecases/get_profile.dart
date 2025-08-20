import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<ProfileEntity?> call(String uid) {
    return repository.getProfile(uid);
  }
}
