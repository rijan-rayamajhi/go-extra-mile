import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/get_carousel_ads_by_location.dart';
import '../bloc/ads_event.dart';
import '../bloc/ads_state.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart';

/// BLoC for managing carousel ads state and operations
class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final GetCarouselAdsByLocation getCarouselAdsByLocation;
  final LocationService _locationService;

  AdsBloc({
    required this.getCarouselAdsByLocation,
    LocationService? locationService,
  }) : _locationService = locationService ?? LocationService(),
       super(const AdsInitial()) {
    on<LoadCarouselAdsByLocation>(_onLoadCarouselAdsByLocation);
    on<LoadCarouselAdsWithLocation>(_onLoadCarouselAdsWithLocation);
  }

  /// Handle loading carousel ads by location
  Future<void> _onLoadCarouselAdsByLocation(
    LoadCarouselAdsByLocation event,
    Emitter<AdsState> emit,
  ) async {
    emit(const AdsLoading());
    final result = await getCarouselAdsByLocation(
      GetCarouselAdsByLocationParams(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    result.fold(
      (failure) => emit(AdsError(message: failure.message)),
      (ads) => emit(ads.isEmpty ? const AdsEmpty() : AdsLoaded(ads: ads)),
    );
  }

  /// Handle loading carousel ads with automatic location fetching
  Future<void> _onLoadCarouselAdsWithLocation(
    LoadCarouselAdsWithLocation event,
    Emitter<AdsState> emit,
  ) async {
    emit(const AdsLoading());
    
    try {
      // Check if location service is enabled
      if (!await _locationService.isLocationServiceEnabled()) {
        debugPrint('Location service is not enabled');
        emit(const AdsError(message: 'Location service is not enabled'));
        return;
      }

      // Check and request location permissions
      LocationPermission permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
        emit(const AdsError(message: 'Location permission is required'));
        return;
      }

      // Get current position
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        debugPrint('Could not get current position');
        emit(const AdsError(message: 'Could not get current location'));
        return;
      }

      // Load ads with the obtained location
      final result = await getCarouselAdsByLocation(
        GetCarouselAdsByLocationParams(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      result.fold(
        (failure) => emit(AdsError(message: failure.message)),
        (ads) => emit(ads.isEmpty ? const AdsEmpty() : AdsLoaded(ads: ads)),
      );
      
    } catch (e) {
      debugPrint('Error loading ads with location: $e');
      emit(AdsError(message: 'Failed to load ads: ${e.toString()}'));
    }
  }
}
