import '../../domain/entities/carousel_ad.dart';
import '../../domain/repository/carousel_ad_repository.dart';
import '../datasources/carousel_ad_datasource.dart';
import '../model/carousel_ad_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import 'package:dartz/dartz.dart';

class CarouselAdRepositoryImpl implements CarouselAdRepository {
  final CarouselAdDataSource dataSource;

  CarouselAdRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<CarouselAd>>> getCarouselAdsByLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final List<CarouselAdModel> models = await dataSource
          .getCarouselAdsByLocation(latitude: latitude, longitude: longitude);

      // Filter ads based on scheduling
      final List<CarouselAd> filteredAds = models
          .where((model) => _isAdCurrentlyActive(model))
          .map((model) => model as CarouselAd)
          .toList();

      return Right(filteredAds);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Check if an ad is currently active based on scheduling
  bool _isAdCurrentlyActive(CarouselAdModel model) {
    if (!model.scheduling.enabled) {
      return true; // If scheduling is disabled, ad is always active
    }

    final now = DateTime.now();

    if (model.scheduling.startDate != null &&
        now.isBefore(model.scheduling.startDate!)) {
      return false; // Ad hasn't started yet
    }

    if (model.scheduling.endDate != null &&
        now.isAfter(model.scheduling.endDate!)) {
      return false; // Ad has expired
    }

    return true; // Ad is currently active
  }
}
