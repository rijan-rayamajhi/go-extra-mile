import '../entities/carousel_ad.dart';
import '../repository/carousel_ad_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

class GetCarouselAdsByLocationParams {
  final double latitude;
  final double longitude;

  GetCarouselAdsByLocationParams({
    required this.latitude,
    required this.longitude,
  });
}

class GetCarouselAdsByLocation
    implements UseCase<List<CarouselAd>, GetCarouselAdsByLocationParams> {
  final CarouselAdRepository repository;

  GetCarouselAdsByLocation(this.repository);

  @override
  Future<Either<Failure, List<CarouselAd>>> call(
    GetCarouselAdsByLocationParams params,
  ) async {
    return await repository.getCarouselAdsByLocation(
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}
