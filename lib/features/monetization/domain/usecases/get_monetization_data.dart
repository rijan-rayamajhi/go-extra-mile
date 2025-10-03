import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/core/usecases/usecase.dart';
import '../entities/monetization_data_entity.dart';
import '../repositories/monetization_repository.dart';

class GetMonetizationData implements UseCase<MonetizationDataEntity, NoParams> {
  final MonetizationRepository repository;

  GetMonetizationData(this.repository);

  @override
  Future<Either<Failure, MonetizationDataEntity>> call(NoParams params) async {
    return await repository.getMonetizationData();
  }
}
