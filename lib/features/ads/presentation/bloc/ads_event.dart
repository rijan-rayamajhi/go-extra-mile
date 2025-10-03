import 'package:equatable/equatable.dart';

/// Abstract base class for all ads events
abstract class AdsEvent extends Equatable {
  const AdsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all carousel ads
class LoadCarouselAds extends AdsEvent {
  const LoadCarouselAds();
}

/// Event to load carousel ads by location
class LoadCarouselAdsByLocation extends AdsEvent {
  final double latitude;
  final double longitude;

  const LoadCarouselAdsByLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
