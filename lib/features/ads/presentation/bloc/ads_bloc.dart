import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_carousel_ads_by_location.dart';
import '../bloc/ads_event.dart';
import '../bloc/ads_state.dart';

/// BLoC for managing carousel ads state and operations
class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final GetCarouselAdsByLocation getCarouselAdsByLocation;

  AdsBloc({required this.getCarouselAdsByLocation})
    : super(const AdsInitial()) {
    on<LoadCarouselAdsByLocation>(_onLoadCarouselAdsByLocation);
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
}
