import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ads/presentation/bloc/ads_bloc.dart';
import 'package:go_extra_mile_new/features/ads/presentation/bloc/ads_event.dart';
import 'package:go_extra_mile_new/features/ads/presentation/bloc/ads_state.dart';
import 'package:go_extra_mile_new/features/ads/domain/entities/carousel_ad.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, state) {
        if (state is AdsInitial) {
          if (!_hasLoadedAds) {
            _hasLoadedAds = true;
            // Use the new bloc event that handles location internally
            context.read<AdsBloc>().add(const LoadCarouselAdsWithLocation());
          }
          return _buildShimmerPlaceholder();
        }
        if (state is AdsLoading) {
          return _buildShimmerPlaceholder();
        } else if (state is AdsLoaded) {
          return _buildCarousel(state.ads);
        } else if (state is AdsEmpty) {
          return _builEmptyPlaceholder();
        } else if (state is AdsError) {
          return _buildErrorPlaceholder(state.message);
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
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              );
            },

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

  Widget _buildErrorPlaceholder(String message) {
    return AspectRatio(
      aspectRatio: 16 / 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            const Text('Something went wrong'),
            TextButton(
              onPressed: () {
                context.read<AdsBloc>().add(
                  const LoadCarouselAdsWithLocation(),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _builEmptyPlaceholder() => AspectRatio(
    aspectRatio: 16 / 12,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade50],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 32),
          // App name
          Text(
            'Go Extra Mile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Tagline
          Text(
            'Commute • Ride • Travel',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Reward section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Earn Rewards',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
