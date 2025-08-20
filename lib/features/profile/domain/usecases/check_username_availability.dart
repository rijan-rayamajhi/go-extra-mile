import 'package:go_extra_mile_new/features/profile/domain/repositories/profile_repository.dart';

class CheckUsernameAvailability {
  final ProfileRepository repository;

  CheckUsernameAvailability(this.repository);

  Future<bool> call(String username) async {
    return await repository.isUsernameAvailable(username);
  }
} 