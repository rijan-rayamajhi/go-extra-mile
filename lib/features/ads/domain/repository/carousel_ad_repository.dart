import '../entities/carousel_ad.dart';
import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class CarouselAdRepository {
  /// Get carousel ads by location (if location targeting is enabled)
  Future<Either<Failure, List<CarouselAd>>> getCarouselAdsByLocation({
    required double latitude,
    required double longitude,
  });
}
