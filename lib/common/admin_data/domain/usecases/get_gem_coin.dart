import '../entities/gem_coin.dart';
import '../repository/admin_data_repository.dart';

class GetGemCoin {
  final AdminDataRepository repository;

  GetGemCoin(this.repository);

  Future<GemCoin> call() async {
    return await repository.getGemCoin();
  }
} 