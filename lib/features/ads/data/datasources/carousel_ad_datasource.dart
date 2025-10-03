import '../model/carousel_ad_model.dart';

abstract class CarouselAdDataSource {
  /// Get carousel ads by location from remote data source
  Future<List<CarouselAdModel>> getCarouselAdsByLocation({
    required double latitude,
    required double longitude,
  });
}
