import 'package:go_extra_mile_new/features/home/domain/home_repositories.dart';

class GetUserProfileImage {
  final HomeRepository repository;

  GetUserProfileImage(this.repository);

  Future<String?> call() async {
    return await repository.getUserProfileImage();
  }
}
