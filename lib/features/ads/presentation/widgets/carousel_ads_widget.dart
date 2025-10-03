import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ads/presentation/bloc/ads_bloc.dart';
import 'package:go_extra_mile_new/features/ads/presentation/bloc/ads_event.dart';
import 'package:go_extra_mile_new/features/ads/presentation/bloc/ads_state.dart';
import 'package:go_extra_mile_new/features/ads/domain/entities/carousel_ad.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

class CarouselAdsWidget extends StatefulWidget {
  const CarouselAdsWidget({super.key});

  @override
  State<CarouselAdsWidget> createState() => _CarouselAdsWidgetState();
}

class _CarouselAdsWidgetState extends State<CarouselAdsWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasLoadedAds = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAdsWithLocation() async {
    if (_hasLoadedAds) return; // Prevent multiple calls
    _hasLoadedAds = true;

    try {
      final locationService = LocationService();

      if (!await locationService.isLocationServiceEnabled()) return;

      LocationPermission permission = await locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await locationService.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      final position = await locationService.getCurrentPosition();
      if (position != null) {
        context.read<AdsBloc>().add(
          LoadCarouselAdsByLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, state) {
        if (state is AdsInitial) {
          _loadAdsWithLocation();
          return _buildShimmerPlaceholder();
        }
        if (state is AdsLoading) {
          return _buildShimmerPlaceholder();
        } else if (state is AdsLoaded) {
          return _buildCarousel(state.ads);
        } else if (state is AdsEmpty) {
          return _buildPlaceholder();
        } else if (state is AdsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Helper function:
  Widget _buildShimmerPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 12,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(List<CarouselAd> ads) {
    return AspectRatio(
      aspectRatio: 16 / 12,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: ads.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _buildAdItem(ads[index]),
          ),
          if (ads.length > 1) _buildPageIndicators(ads.length),
        ],
      ),
    );
  }

  Widget _buildAdItem(CarouselAd ad) {
    return GestureDetector(
      onTap: () => debugPrint('Ad tapped: ${ad.title}'),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          child: Image.network(
            ad.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) =>
                loadingProgress == null
                ? child
                : Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() => Container(
    color: Colors.grey[300],
    child: const Center(
      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    ),
  );

  Widget _buildPageIndicators(int count) => Positioned(
    bottom: 16,
    left: 0,
    right: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );

  Widget _buildPlaceholder() => AspectRatio(
    aspectRatio: 16 / 12,
    child: Center(child: Text('Go Extra Mile')),
  );
}
