import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/core/usecases/usecase.dart';
import '../repositories/monetization_repository.dart';

class UpdateMonetizationStatus
    implements UseCase<bool, UpdateMonetizationStatusParams> {
  final MonetizationRepository repository;

  UpdateMonetizationStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(
    UpdateMonetizationStatusParams params,
  ) async {
    return await repository.updateMonetizationStatus(params.isMonetized);
  }
}

class UpdateMonetizationStatusParams {
  final bool isMonetized;

  const UpdateMonetizationStatusParams({required this.isMonetized});
}
