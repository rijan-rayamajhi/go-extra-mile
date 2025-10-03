import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/core/usecases/usecase.dart';
import '../repositories/monetization_repository.dart';

class GetMonetizationStatus implements UseCase<bool, NoParams> {
  final MonetizationRepository repository;

  GetMonetizationStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.getMonetizationStatus();
  }
}
