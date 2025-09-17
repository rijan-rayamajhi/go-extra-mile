import '../home_repositories.dart';

class GetStatisticsUseCase {
  final HomeRepository repository;

  GetStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getStatistics();
  }
}
