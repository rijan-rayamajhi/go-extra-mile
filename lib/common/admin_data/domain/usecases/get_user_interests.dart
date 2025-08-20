import '../entities/user_interest.dart';
import '../repository/admin_data_repository.dart';

class GetUserInterests {
  final AdminDataRepository repository;

  GetUserInterests(this.repository);

  Future<UserInterestsData> call() async {
    return await repository.getUserInterests();
  }
} 