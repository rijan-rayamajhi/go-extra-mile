import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class GetCurrentUserProfile {
  final ProfileRepository repository;

  GetCurrentUserProfile(this.repository);

  Future<ProfileEntity?> call() {
    return repository.getCurrentUserProfile();
  }
}
